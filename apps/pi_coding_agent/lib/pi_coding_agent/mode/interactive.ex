defmodule PiCodingAgent.Mode.Interactive do
  @moduledoc """
  Full TUI-based interactive chat mode.

  Built on raw terminal I/O with:
  - Real-time streaming response display
  - Command history (up/down arrows)
  - /commands for meta-actions
  - Model switching
  - Session save/restore
  """

  use GenServer

  alias PiAi.Message

  defstruct [
    :model,
    :renderer,
    messages: [],
    input_buffer: "",
    cursor_pos: 0,
    history: [],
    history_idx: -1,
    status: :idle,
    streaming_buffer: "",
    session_id: nil,
    height: 24
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(opts) do
    model = Keyword.fetch!(opts, :model)
    {:ok, _cols} = :io.columns()
    {:ok, rows} = :io.rows()
    height = min(rows, 24)

    renderer = PiTui.DifferentialRenderer.new(height)

    state = %__MODULE__{
      model: model,
      renderer: renderer,
      height: height
    }

    PiTui.Terminal.enter_raw!()
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    IO.write(:stderr, PiTui.Terminal.hide_cursor())

    draw_header(state, "pi — #{model.name}  |  /help for commands  |  Ctrl+C to exit")
    send(self(), :read_input)
    {:ok, state}
  end

  # === INPUT HANDLING ===

  @impl true
  def handle_info(:read_input, state) do
    # Read raw bytes (handles multi-byte UTF-8 and escape sequences)
    bytes = read_raw_bytes()
    handle_input(bytes, state)
  end

  # === HANDLE INPUT BYTES ===

  defp handle_input("\x03", state) do
    # Ctrl+C
    PiTui.Terminal.exit_raw!()
    IO.write(:stderr, PiTui.Terminal.show_cursor())
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    {:stop, :normal, state}
  end

  defp handle_input("\n", state) do
    # Enter
    if state.input_buffer == "" do
      send(self(), :read_input)
      {:noreply, state}
    else
      submit_prompt(state)
    end
  end

# Carriage return handled as newline

  defp handle_input("\x7f", state) do
    # Backspace
    if state.cursor_pos > 0 do
      buf = String.slice(state.input_buffer, 0, state.cursor_pos - 1) <>
            String.slice(state.input_buffer, state.cursor_pos..-1//1)
      {:noreply, %{state | input_buffer: buf, cursor_pos: state.cursor_pos - 1}, {:continue, :redraw_input}}
    else
      send(self(), :read_input)
      {:noreply, state}
    end
  end

  defp handle_input("\e[A", state) do
    # Up arrow — history back
    idx = if state.history_idx == -1, do: length(state.history) - 1, else: max(state.history_idx - 1, 0)

    if idx >= 0 and idx < length(state.history) do
      text = Enum.at(state.history, idx)
      {:noreply, %{state | input_buffer: text, cursor_pos: String.length(text), history_idx: idx}, {:continue, :redraw_input}}
    else
      send(self(), :read_input)
      {:noreply, state}
    end
  end

  defp handle_input("\e[B", state) do
    # Down arrow — history forward
    if state.history_idx >= 0 and state.history_idx < length(state.history) - 1 do
      idx = state.history_idx + 1
      text = Enum.at(state.history, idx)
      {:noreply, %{state | input_buffer: text, cursor_pos: String.length(text), history_idx: idx}, {:continue, :redraw_input}}
    else
      {:noreply, %{state | input_buffer: "", cursor_pos: 0, history_idx: -1}, {:continue, :redraw_input}}
    end
  end

  defp handle_input("\e[D", state) do
    if state.cursor_pos > 0 do
      {:noreply, %{state | cursor_pos: state.cursor_pos - 1}, {:continue, :redraw_input}}
    else
      send(self(), :read_input)
      {:noreply, state}
    end
  end

  defp handle_input("\e[C", state) do
    if state.cursor_pos < String.length(state.input_buffer) do
      {:noreply, %{state | cursor_pos: state.cursor_pos + 1}, {:continue, :redraw_input}}
    else
      send(self(), :read_input)
      {:noreply, state}
    end
  end

  defp handle_input("\t", state) do
    # Tab — cycle model
    cycle_model(state)
  end

  defp handle_input("\e", state) do
    # Escape — wait for more bytes (arrow sequences start with \e)
    read_escape_sequence(state)
  end

  defp handle_input(byte, state) when is_binary(byte) and byte_size(byte) == 1 do
    # Regular character (including UTF-8 multi-byte)
    buf = String.slice(state.input_buffer, 0, state.cursor_pos) <>
          byte <>
          String.slice(state.input_buffer, state.cursor_pos..-1//1)
    {:noreply, %{state | input_buffer: buf, cursor_pos: state.cursor_pos + byte_size(byte)}, {:continue, :redraw_input}}
  end

  defp handle_input(_, state) do
    send(self(), :read_input)
    {:noreply, state}
  end

  defp read_raw_bytes do
    # Read one byte at a time; collect multi-byte UTF-8
    case IO.getn(:stdio, "", 1) do
      <<byte>> when byte < 128 ->
        # ASCII — single byte
        <<byte>>

      <<byte>> ->
        # Multi-byte UTF-8 — determine continuation bytes needed
        trailing = case byte do
          b when b >= 0xE0 -> 2  # 3-byte
          b when b >= 0xC0 -> 1  # 2-byte
          _ -> 0
        end

        rest = for _ <- 1..trailing, do: IO.getn(:stdio, "", 1)
        <<byte, rest::binary>>

      other ->
        other
    end
  end

  defp read_escape_sequence(state) do
    # After receiving \e, check if more bytes follow (arrow keys send \e[A, etc.)
    case IO.getn(:stdio, "", 1) do
      "[" ->
        case IO.getn(:stdio, "", 1) do
          char when char in ~w(A B C D) ->
            handle_input("\e[#{char}", state)
          _ ->
            send(self(), :read_input)
            {:noreply, state}
        end
      other ->
        handle_input(other, state)
    end
  end

  # === CONTINUATION HANDLERS ===

  @impl true
  def handle_continue(:redraw_input, state) do
    draw_input_line(state)
    send(self(), :read_input)
    {:noreply, state}
  end

  def handle_continue({:stream_response, model, messages}, state) do
    status_line = state.height
    IO.write(:stderr, "\e[#{status_line};1H#{PiTui.Terminal.styled("  Streaming...", :yellow)}\e[0K")
    Task.start(fn -> do_stream_response(self(), model, messages) end)
    {:noreply, %{state | status: :streaming, streaming_buffer: ""}}
  end

  # === STREAMING RESPONSE ===

  defp do_stream_response(pid, model, messages) do
    result =
      case model.api do
        "anthropic-messages" -> PiAi.Provider.Anthropic.stream_chat(model, messages, [])
        "openai-responses" -> PiAi.Provider.OpenAI.stream_chat(model, messages, [])
        "google-generative-ai" -> PiAi.Provider.Gemini.stream_chat(model, messages, [])
        _ -> PiAi.Provider.OpenAICompat.stream_chat("https://api.openai.com/v1/chat/completions", model, messages, [], model.provider)
      end

    case result do
      {:ok, [response]} ->
        response_text = response["content"] || ""
        GenServer.cast(pid, {:add_response, response_text})
      {:error, reason} ->
        GenServer.cast(pid, {:stream_error, reason})
    end
  end

  @impl true
  def handle_cast({:add_response, text}, state) do
    new_messages = state.messages ++ [%Message{role: :assistant, content: text}]
    history = [state.input_buffer | state.history]
    state = %{state | messages: new_messages, status: :idle, input_buffer: "", cursor_pos: 0, history: history, history_idx: -1}

    # Auto-save session
    session_id = state.session_id || PiCodingAgent.Session.save(new_messages)
    state = %{state | session_id: session_id}

    redraw_messages(state, new_messages)
    draw_status_bar(state, "Ready. /help for commands.")
    draw_input_line(state)
    send(self(), :read_input)
    {:noreply, state}
  end

  def handle_cast({:stream_error, reason}, state) do
    state = %{state | status: :idle}
    draw_status_bar(state, "Error: #{reason}")
    draw_input_line(state)
    send(self(), :read_input)
    {:noreply, state}
  end

  # === SUBMIT PROMPT ===

  defp submit_prompt(state) do
    text = state.input_buffer

    cond do
      String.starts_with?(text, "/") ->
        handle_command(text, state)

      true ->
        user_msg = %Message{role: :user, content: text}
        new_messages = state.messages ++ [user_msg]
        state = %{state | messages: new_messages, input_buffer: "", cursor_pos: 0, status: :streaming}

        redraw_messages(state, new_messages)
        draw_status_bar(state, "Streaming...")

        {:noreply, state, {:continue, {:stream_response, state.model, new_messages}}}
    end
  end

  # === COMMANDS ===

  defp handle_command("/help", state) do
    help = """
    /help       Show this help
    /clear      Clear the conversation
    /save       Save the current session
    /sessions   List saved sessions
    /export     Export conversation as HTML
    /models     List available models
    /model ID   Switch to a model (Tab also cycles)
    /diagnostics Show system diagnostics
    /exit       Exit pi
    """

    draw_status_bar(state, help)
    send(self(), :read_input)
    {:noreply, %{state | input_buffer: "", cursor_pos: 0}}
  end

  defp handle_command("/clear", state) do
    state = %{state | messages: [], session_id: nil}
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    draw_header(state, "pi — #{state.model.name}  |  Conversation cleared")
    draw_status_bar(state, "Conversation cleared.")
    draw_input_line(state)
    send(self(), :read_input)
    {:noreply, state}
  end

  defp handle_command("/save", state) do
    sid = PiCodingAgent.Session.save(state.messages)
    draw_status_bar(state, "Session saved: #{sid}")
    send(self(), :read_input)
    {:noreply, %{state | input_buffer: "", cursor_pos: 0, session_id: sid}}
  end

  defp handle_command("/models", state) do
    models = PiAi.Providers.all_models()
    names = Enum.map(models, &("#{&1.id}  [#{&1.provider}]"))
    list = Enum.join(Enum.take_random(names, 20), "\n")
    draw_status_bar(state, "Models (#{length(models)} total, showing 20):\n#{list}")
    send(self(), :read_input)
    {:noreply, %{state | input_buffer: "", cursor_pos: 0}}
  end

  defp handle_command("/model " <> id, state) do
    case PiAi.Providers.find_model(id) do
      {:ok, model} ->
        draw_header(state, "pi — #{model.name}  |  Switched to #{model.id}")
        draw_status_bar(state, "Switched to #{model.id}")
        send(self(), :read_input)
        {:noreply, %{state | model: model, input_buffer: "", cursor_pos: 0}}
      {:error, reason} ->
        draw_status_bar(state, reason)
        send(self(), :read_input)
        {:noreply, %{state | input_buffer: "", cursor_pos: 0}}
    end
  end

  defp handle_command("/sessions", state) do
    sessions = PiCodingAgent.Session.list()

    case sessions do
      [] ->
        draw_status_bar(state, "No saved sessions.")

      sessions ->
        lines =
          sessions
          |> Enum.take(10)
          |> Enum.map(fn s ->
            count = length(s["messages"] || [])
            ts = String.slice(s["timestamp"] || "unknown", 0, 19)
            id = String.slice(s["session_id"] || "?", 0, 16)
            "  #{id} - #{count} msgs - #{ts}"
          end)

        draw_status_bar(state, "Sessions (last 10):\n" <> Enum.join(lines, "\n"))
    end

    send(self(), :read_input)
    {:noreply, %{state | input_buffer: "", cursor_pos: 0}}
  end

  defp handle_command("/export", state) do
    path = "conversation_#{:erlang.system_time()}.html"
    PiCodingAgent.ExportHTML.export(state.messages, path)
    draw_status_bar(state, "Exported to #{path}")
    send(self(), :read_input)
    {:noreply, %{state | input_buffer: "", cursor_pos: 0}}
  end

  defp handle_command("/diagnostics", state) do
    PiCodingAgent.Diagnostics.print()
    draw_status_bar(state, "Diagnostics printed above.")
    send(self(), :read_input)
    {:noreply, %{state | input_buffer: "", cursor_pos: 0}}
  end

  defp handle_command("/exit", state) do
    PiTui.Terminal.exit_raw!()
    IO.write(:stderr, PiTui.Terminal.show_cursor())
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    {:stop, :normal, state}
  end

  defp handle_command(cmd, state) do
    draw_status_bar(state, "Unknown command: #{cmd}. Type /help")
    send(self(), :read_input)
    {:noreply, %{state | input_buffer: "", cursor_pos: 0}}
  end

  defp cycle_model(state) do
    models = PiAi.Providers.all_models()
    current_idx = Enum.find_index(models, &(&1.id == state.model.id))

    case current_idx do
      nil ->
        {:noreply, state, {:continue, :redraw_input}}

      idx ->
        next_idx = rem(idx + 1, length(models))
        next = Enum.at(models, next_idx)
        state = %{state | model: next}
        draw_header(state, "pi — #{next.name}  |  Switched to #{next.id}")
        send(self(), :read_input)
        {:noreply, state}
    end
  end

  # === RENDERING ===

  defp draw_header(_state, text) do
    {_rows, cols} = PiTui.Terminal.size()
    padded = String.pad_trailing(text, cols - 1)
    IO.write(:stderr, "\e[1;1H#{PiTui.Terminal.styled(padded, :reverse)}\e[0K")
  end

  defp draw_status_bar(state, text) do
    {_rows, cols} = PiTui.Terminal.size()
    line = state.height
    lines = String.split(text, "\n")
    Enum.each(Enum.with_index(lines), fn {l, i} ->
      pos = line + i
      if pos <= state.height do
        padded = String.pad_trailing(l, cols - 1)
        IO.write(:stderr, "\e[#{pos};1H#{PiTui.Terminal.styled(padded, :dim)}\e[0K")
      end
    end)
  end

  defp redraw_messages(state, messages) do
    visible = state.height - 2

    lines =
      messages
      |> Enum.flat_map(fn msg ->
        role_label = case msg.role do
          :user -> "> #{PiTui.Terminal.styled("You:", :green)}"
          :assistant -> "> #{PiTui.Terminal.styled("AI:", :cyan)}"
          :system -> "> #{PiTui.Terminal.styled("System:", :yellow)}"
          _ -> "> #{msg.role}:"
        end

        content = msg.content || ""
        wrapped = wrap_text(content, 70)
        [role_label] ++ Enum.map(wrapped, &("  #{&1}")) ++ [""]
      end)
      |> Enum.take(-visible)

    padding = visible - length(lines)
    padded = if padding > 0, do: lines ++ List.duplicate("", padding), else: lines

    {_renderer, output} = PiTui.DifferentialRenderer.render(state.renderer, padded)
    IO.write(:stderr, output)
  end

  defp draw_input_line(state) do
    {_rows, cols} = PiTui.Terminal.size()
    prompt = "> #{state.input_buffer}"
    # String.slice(prompt, 0, cols - 1)  # truncated removed
    cursor_offset = min(2 + state.cursor_pos, cols - 1)

    input_line = state.height - 1
    IO.write(:stderr, "\e[#{input_line};1H#{PiTui.Terminal.styled(prompt, :bold)}\e[0K")
    IO.write(:stderr, "\e[#{input_line};#{cursor_offset}H")
  end

  defp wrap_text(text, width) do
    String.split(text, "\n")
    |> Enum.flat_map(fn line ->
      if String.length(line) <= width do
        [line]
      else
        do_wrap(line, width, [])
      end
    end)
  end

  defp do_wrap("", _width, acc), do: Enum.reverse(acc)
  defp do_wrap(text, width, acc) do
    if String.length(text) <= width do
      Enum.reverse([text | acc])
    else
      {chunk, rest} = String.split_at(text, width)
      do_wrap(rest, width, [chunk | acc])
    end
  end
end
