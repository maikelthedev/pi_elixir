defmodule PiCodingAgent.Mode.Interactive do
  @moduledoc """
  Interactive mode — full TUI-based chat interface.

  Manages the conversation session, renders messages,
  handles keyboard input, and coordinates streaming responses.
  """

  use GenServer

  alias PiAi.Message

  defstruct [
    :model,
    :renderer,
    messages: [],
    input_buffer: "",
    cursor_pos: 0,
    status: :idle,
    streaming_buffer: ""
  ]

  # Client API

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  # Server callbacks

  @impl true
  def init(opts) do
    model = Keyword.fetch!(opts, :model)
    {:ok, _cols} = :io.columns()
    {:ok, rows} = :io.rows()
    height = min(rows, 24)

    renderer = PiTui.DifferentialRenderer.new(height)

    state = %__MODULE__{
      model: model,
      renderer: renderer
    }

    PiTui.Terminal.enter_raw!()
    IO.write(:stderr, PiTui.Terminal.clear_screen())
    IO.write(:stderr, PiTui.Terminal.hide_cursor())

    render_status(state, "Ready. Type your prompt, Ctrl+C to exit.")

    send(self(), :read_input)
    {:ok, state}
  end

  @impl true
  def handle_info(:read_input, state) do
    char = IO.getn(:stdio, "", 1)

    case char do
      "\x03" ->
        # Ctrl+C - exit
        PiTui.Terminal.exit_raw!()
        IO.write(:stderr, PiTui.Terminal.show_cursor())
        IO.write(:stderr, PiTui.Terminal.clear_screen())
        {:stop, :normal, state}

      "\n" ->
        # Enter - submit
        submit_prompt(state)

      "\x7f" ->
        # Backspace
        if state.cursor_pos > 0 do
          buf = String.slice(state.input_buffer, 0, state.cursor_pos - 1) <>
                String.slice(state.input_buffer, state.cursor_pos..-1//1)
          {:noreply, %{state | input_buffer: buf, cursor_pos: state.cursor_pos - 1}, {:continue, :redraw_input}}
        else
          send(self(), :read_input)
          {:noreply, state}
        end

      "\e[A" ->
        # Up arrow - nothing yet (history)
        send(self(), :read_input)
        {:noreply, state}

      "\e[D" ->
        # Left arrow
        if state.cursor_pos > 0 do
          {:noreply, %{state | cursor_pos: state.cursor_pos - 1}, {:continue, :redraw_input}}
        else
          send(self(), :read_input)
          {:noreply, state}
        end

      "\e[C" ->
        # Right arrow
        if state.cursor_pos < String.length(state.input_buffer) do
          {:noreply, %{state | cursor_pos: state.cursor_pos + 1}, {:continue, :redraw_input}}
        else
          send(self(), :read_input)
          {:noreply, state}
        end

      "\t" ->
        # Tab - ignore for now
        send(self(), :read_input)
        {:noreply, state}

      other when is_binary(other) and byte_size(other) == 1 ->
        # Regular character
        buf = String.slice(state.input_buffer, 0, state.cursor_pos) <>
              other <>
              String.slice(state.input_buffer, state.cursor_pos..-1//1)
        {:noreply, %{state | input_buffer: buf, cursor_pos: state.cursor_pos + 1}, {:continue, :redraw_input}}

      _ ->
        send(self(), :read_input)
        {:noreply, state}
    end
  end

  @impl true
  def handle_continue(:redraw_input, state) do
    draw_input_line(state)
    send(self(), :read_input)
    {:noreply, state}
  end

  def handle_continue({:stream_response, model, messages}, state) do
    # Start streaming the response
    Task.start(fn -> do_stream_response(self(), model, messages) end)
    {:noreply, %{state | status: :streaming, streaming_buffer: ""}}
  end

  # Private

  defp submit_prompt(state) do
    prompt = state.input_buffer

    if prompt == "" do
      send(self(), :read_input)
      {:noreply, state}
    else
      user_msg = %Message{role: :user, content: prompt}

      # Add to message list and redraw
      new_messages = state.messages ++ [user_msg]
      state = %{state | messages: new_messages, input_buffer: "", status: :streaming}

      # Insert the user message into the visible area
      render_messages(state, new_messages)

      {:noreply, state, {:continue, {:stream_response, state.model, new_messages}}}
    end
  end

  defp do_stream_response(pid, model, messages) do
    # Call the provider
    result =
      case model.api do
        "anthropic-messages" ->
          PiAi.Provider.Anthropic.stream_chat(model, messages, [])

        "openai-responses" ->
          PiAi.Provider.OpenAI.stream_chat(model, messages, [])

        "google-generative-ai" ->
          PiAi.Provider.Gemini.stream_chat(model, messages, [])

        _ ->
          {:error, "Unknown API: #{model.api}"}
      end

    case result do
      {:ok, [response]} ->
        # Process response
        response_text = response["content"] || ""

        # Create assistant message
        assistant_msg = %Message{role: :assistant, content: response_text}

        # Add to history
        GenServer.cast(pid, {:add_response, assistant_msg})

      {:error, reason} ->
        GenServer.cast(pid, {:stream_error, reason})
    end
  end

  @impl true
  def handle_cast({:add_response, message}, state) do
    new_messages = state.messages ++ [message]
    state = %{state | messages: new_messages, status: :idle}

    render_messages(state, new_messages)
    draw_input_line(state)

    send(self(), :read_input)
    {:noreply, state}
  end

  def handle_cast({:stream_error, reason}, state) do
    state = %{state | status: :idle}
    render_status(state, "Error: #{reason}")
    draw_input_line(state)
    send(self(), :read_input)
    {:noreply, state}
  end

  def handle_cast({:stream_chunk, text}, state) do
    buffer = state.streaming_buffer <> text
    state = %{state | streaming_buffer: buffer}
    # Could update status line here for streaming feedback
    {:noreply, state}
  end

  # Rendering

  defp render_messages(state, messages) do
    visible = state.renderer.height - 2  # Reserve 2 lines for input+status

    # Take last N messages to display
    lines =
      messages
      |> Enum.flat_map(fn msg ->
        role_label = case msg.role do
          :user -> "> You:"
          :assistant -> "> AI:"
          :system -> "> System:"
          :tool -> "> Tool(#{msg.name || "?"}):"
          _ -> "> #{msg.role}:"
        end

        content = msg.content || ""
        wrapped = wrap_text(content, 70)
        [PiTui.Terminal.styled(role_label, :cyan)] ++
          Enum.map(wrapped, &("  " <> &1)) ++ [""]
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
    padded = String.pad_trailing(prompt, cols - 1)
    cursor_offset = 3 + state.cursor_pos  # "> " prefix offset

    input_line = state.renderer.height - 1
    IO.write(:stderr, "\e[#{input_line};1H#{padded}\e[0K")  # Draw input
    IO.write(:stderr, "\e[#{input_line};#{cursor_offset}H")  # Position cursor
  end

  defp render_status(state, text) do
    {_rows, cols} = PiTui.Terminal.size()
    line = state.renderer.height
    padded = String.pad_trailing(text, cols - 1)
    IO.write(:stderr, "\e[#{line};1H#{PiTui.Terminal.styled(padded, :dim)}\e[0K")
  end

  defp wrap_text(text, width) do
    String.split(text, "\n")
    |> Enum.flat_map(fn line ->
      if String.length(line) <= width do
        [line]
      else
        wrap_line(line, width)
      end
    end)
  end

  defp wrap_line(text, width) do
    do_wrap(text, width, [])
  end

  defp do_wrap("", _width, acc), do: Enum.reverse(acc)

  defp do_wrap(text, width, acc) do
    case String.length(text) <= width do
      true -> Enum.reverse([text | acc])
      false ->
        {chunk, rest} = String.split_at(text, width)
        do_wrap(rest, width, [chunk | acc])
    end
  end
end
