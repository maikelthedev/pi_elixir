defmodule PiCodingAgent.Mode.Interactive do
  @moduledoc """
  Full TUI interactive chat mode with proper components.
  """
  use GenServer
  alias PiAi.Message

  defstruct [
    :model, :renderer, :input_state, :input,
    messages: [], status: :idle, session_id: nil,
    height: 24, width: 80, streaming_text: ""
  ]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  @impl true
  def init(opts) do
    model = Keyword.fetch!(opts, :model)
    {:ok, cols} = :io.columns()
    {:ok, rows} = :io.rows()
    height = min(rows, 24)

    renderer = PiTui.DifferentialRenderer.new(height)
    input = PiTui.Component.Input.new(prompt: "> ")

    state = %__MODULE__{
      model: model, renderer: renderer, input: input,
      height: height, width: cols
    }

    PiTui.Terminal.enter_raw!()
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    IO.write(:stderr, PiTui.Terminal.hide_cursor())
    render_footer(state, "Ready. #{model.name} | /help for commands")

    send(self(), :read_input)
    {:ok, state}
  end

  @impl true
  def handle_info(:read_input, state) do
    try do
      byte = IO.getn(:stdio, "", 1)
      new_state = handle_byte(state, byte || "")
      redraw_input(new_state)
      send(self(), :read_input)
      {:noreply, new_state}
    rescue
      e ->
        IO.write(:stderr, "\nInput error: #{inspect(e)}\n")
        send(self(), :read_input)
        {:noreply, state}
    end
  end

  def handle_info({:response, text}, state) do
    msg = %Message{role: :assistant, content: text}
    new_messages = state.messages ++ [msg]
    sid = state.session_id || PiCodingAgent.Session.save(new_messages)
    state = %{state | messages: new_messages, status: :idle, session_id: sid}
    redraw_conversation(state)
    render_footer(state, "Ready. Session: #{String.slice(sid || "", 0, 16)}")
    {:noreply, state}
  end

  def handle_info({:error, reason}, state) do
    state = %{state | status: :error}
    render_footer(state, "Error: #{reason}")
    {:noreply, state}
  end

  # === Commands ===
  # === Byte handling ===

  defp handle_byte(_state, "\x03") do
    PiTui.Terminal.exit_raw!()
    IO.write(:stderr, PiTui.Terminal.show_cursor())
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    exit(:normal)
  end

  defp handle_byte(state, "\n") do
    {input, text} = PiTui.Component.Input.submit(state.input)
    if text, do: submit_prompt(%{state | input: input}, text), else: state
  end

  defp handle_byte(state, "\r"), do: handle_byte(state, "\n")

  defp handle_byte(state, "\x7f") do
    %{state | input: PiTui.Component.Input.delete(state.input)}
  end

  defp handle_byte(state, "\e") do
    case IO.getn(:stdio, "", 1) do
      "[" ->
        case IO.getn(:stdio, "", 1) do
          "A" -> %{state | input: PiTui.Component.Input.history_prev(state.input)}
          "B" -> %{state | input: PiTui.Component.Input.history_next(state.input)}
          "C" -> %{state | input: PiTui.Component.Input.cursor_right(state.input)}
          "D" -> %{state | input: PiTui.Component.Input.cursor_left(state.input)}
          _ -> state
        end
      _ -> state
    end
  end

  defp handle_byte(state, "\t") do
    models = PiAi.Providers.all_models()
    idx = Enum.find_index(models, &(&1.id == state.model.id))
    next = Enum.at(models, rem((idx || 0) + 1, length(models)))
    new_state = %{state | model: next}
    render_footer(new_state, "Switched to #{next.id}")
    new_state
  end

  defp handle_byte(state, byte) when byte_size(byte) == 1 do
    %{state | input: PiTui.Component.Input.insert(state.input, byte)}
  end

  defp handle_byte(state, _), do: state

  # === Submit prompt ===

  defp submit_prompt(state, text) do
    if String.starts_with?(text, "/") do
      handle_command(state, text)
    else
      user_msg = %Message{role: :user, content: text}
      new_messages = state.messages ++ [user_msg]
      state = %{state | messages: new_messages, status: :streaming}

      redraw_conversation(state)
      render_footer(state, " ⟳ Streaming...")

      Task.start(fn -> do_stream(self(), state.model, new_messages) end)
      state
    end
  end

  defp do_stream(pid, model, messages) do
    result =
      case model.api do
        "anthropic-messages" -> PiAi.Provider.Anthropic.stream_chat(model, messages, [])
        "openai-responses" -> PiAi.Provider.OpenAI.stream_chat(model, messages, [])
        "google-generative-ai" -> PiAi.Provider.Gemini.stream_chat(model, messages, [])
        _ -> PiAi.Provider.OpenAICompat.stream_chat("https://api.openai.com/v1/chat/completions", model, messages, [], model.provider)
      end

    case result do
      {:ok, [response]} ->
        text = response["content"] || ""
        send(pid, {:response, text})
      {:error, reason} ->
        send(pid, {:error, inspect(reason)})
    end
  end
  defp handle_command(state, "/help") do
    render_footer(state, "/help /clear /save /sessions /export /models /model /diagnostics /exit")
    state
  end

  defp handle_command(state, "/clear") do
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    render_footer(%{state | messages: [], session_id: nil}, "Conversation cleared.")
  end

  defp handle_command(state, "/save") do
    sid = PiCodingAgent.Session.save(state.messages)
    render_footer(%{state | session_id: sid}, "Saved: #{sid}")
  end

  defp handle_command(state, "/sessions") do
    sessions = PiCodingAgent.Session.list()
    text = case sessions do
      [] -> "No saved sessions."
      s -> Enum.map(Enum.take(s, 5), fn x -> "  #{String.slice(x["session_id"] || "", 0, 20)}" end) |> Enum.join("\n")
    end
    render_footer(state, "Sessions:\n#{text}")
    state
  end

  defp handle_command(state, "/export") do
    path = "conversation_#{:os.system_time(:second)}.html"
    PiCodingAgent.ExportHTML.export(state.messages, path)
    render_footer(state, "Exported to #{path}")
    state
  end

  defp handle_command(state, "/models") do
    count = length(PiAi.Providers.all_models())
    render_footer(state, "#{count} models available. Tab to cycle, /model <id> to switch.")
    state
  end

  defp handle_command(state, "/diagnostics") do
    PiCodingAgent.Diagnostics.print()
    state
  end

  defp handle_command(_state, "/exit") do
    PiTui.Terminal.exit_raw!()
    IO.write(:stderr, PiTui.Terminal.show_cursor())
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    exit(:normal)
  end

  defp handle_command(state, _cmd) do
    render_footer(state, "Unknown. Try /help")
    state
  end

  # === Rendering ===

  defp redraw_conversation(state) do
    visible = state.height - 1
    lines = build_conversation_lines(state.messages, visible)
    {_r, output} = PiTui.DifferentialRenderer.render(state.renderer, lines)
    IO.write(:stderr, output)
  end

  defp render_footer(state, text) do
    line = state.height
    display = PiTui.Component.Footer.status_line(text)
    IO.write(:stderr, "\e[#{line};1H#{display}\e[0K")
  end

  defp redraw_input(state) do
    input_line = state.height
    {display, cursor} = PiTui.Component.Input.render(state.input, state.width)
    IO.write(:stderr, "\e[#{input_line};1H#{display}\e[0K")
    IO.write(:stderr, "\e[#{input_line};#{min(cursor + 1, state.width)}H")
  end

  defp build_conversation_lines(messages, max) do
    messages
    |> Enum.flat_map(fn msg ->
      role_label = case msg.role do
        :user -> PiTui.Terminal.styled("You:", :green)
        :assistant -> PiTui.Terminal.styled("AI:", :cyan)
        _ -> Atom.to_string(msg.role)
      end
      ["> #{role_label}"] ++
        (msg.content || "")
        |> String.split("\n")
        |> Enum.map(&("  #{&1}"))
    end)
    |> Enum.take(-max)
  end
end
