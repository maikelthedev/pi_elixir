defmodule PiTui.Component.Input do
  @moduledoc """
  Single-line text input component with cursor and history support.
  """

  defstruct [:buffer, :cursor, :history, :history_idx, :prompt]

  @type t :: %__MODULE__{
    buffer: String.t(),
    cursor: non_neg_integer(),
    history: [String.t()],
    history_idx: integer(),
    prompt: String.t()
  }

  @doc "Creates a new input state."
  def new(opts \\ []) do
    %__MODULE__{
      buffer: Keyword.get(opts, :buffer, ""),
      cursor: Keyword.get(opts, :cursor, 0),
      prompt: Keyword.get(opts, :prompt, "> "),
      history: Keyword.get(opts, :history, []),
      history_idx: -1
    }
  end

  @doc "Inserts a character at cursor position."
  def insert(%__MODULE__{buffer: buf, cursor: c} = input, char) do
    new_buf = String.slice(buf, 0, c) <> char <> String.slice(buf, c..-1//1)
    %{input | buffer: new_buf, cursor: c + String.length(char)}
  end

  @doc "Deletes character before cursor."
  def delete(%__MODULE__{cursor: 0} = input), do: input
  def delete(%__MODULE__{buffer: buf, cursor: c} = input) do
    new_buf = String.slice(buf, 0, c - 1) <> String.slice(buf, c..-1//1)
    %{input | buffer: new_buf, cursor: c - 1}
  end

  @doc "Moves cursor left."
  def cursor_left(%__MODULE__{cursor: 0} = input), do: input
  def cursor_left(%__MODULE__{cursor: c} = input), do: %{input | cursor: c - 1}

  @doc "Moves cursor right."
  def cursor_right(%__MODULE__{buffer: buf, cursor: c} = input) do
    if c < String.length(buf), do: %{input | cursor: c + 1}, else: input
  end

  def cursor_home(%__MODULE__{} = input), do: %{input | cursor: 0}

  def cursor_end(%__MODULE__{buffer: buf} = input), do: %{input | cursor: String.length(buf)}

  @doc "Goes to previous history entry."
  def history_prev(%__MODULE__{history: [], history_idx: -1} = input), do: input
  def history_prev(%__MODULE__{history: h, history_idx: -1} = input) when h != [] do
    %{input | buffer: List.last(h), history_idx: length(h) - 1, cursor: String.length(List.last(h))}
  end
  def history_prev(%__MODULE__{history: h, history_idx: i} = input) when i > 0 do
    entry = Enum.at(h, i - 1)
    %{input | buffer: entry, history_idx: i - 1, cursor: String.length(entry)}
  end
  def history_prev(%__MODULE__{} = input), do: input

  @doc "Goes to next history entry."
  def history_next(%__MODULE__{history_idx: -1} = input), do: input
  def history_next(%__MODULE__{history: h, history_idx: i} = input) when i < length(h) - 1 do
    entry = Enum.at(h, i + 1)
    %{input | buffer: entry, history_idx: i + 1, cursor: String.length(entry)}
  end
  def history_next(%__MODULE__{} = input), do: %{input | buffer: "", history_idx: -1, cursor: 0}

  @doc "Submits current buffer, adds to history. Returns {new_input_state, submitted_text}."
  def submit(%__MODULE__{buffer: ""} = input), do: {input, nil}
  def submit(%__MODULE__{} = input) do
    text = input.buffer
    new_history = [text | input.history] |> Enum.take(100)
    {%{input | buffer: "", cursor: 0, history: new_history, history_idx: -1}, text}
  end

  @doc "Renders the input line. Returns {display_string, cursor_offset}."
  def render(%__MODULE__{buffer: buf, cursor: c, prompt: p} = _input, cols) do
    display = p <> buf
    truncated = String.slice(display, 0, cols - 1)
    cursor_offset = String.length(p) + min(c, cols - 1 - String.length(p))
    {truncated, cursor_offset}
  end
end
