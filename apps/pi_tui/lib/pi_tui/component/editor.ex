defmodule PiTui.Component.Editor do
  @moduledoc """
  Multi-line text editor component.

  Supports line editing, cursor movement, insert/overwrite modes,
  selection, and clipboard operations.
  """

  defstruct [
    :buffer, :cursor_line, :cursor_col,
    :scroll_offset, :mode, :selection,
    :undo_stack, :kill_ring, :tab_width
  ]

  @type t :: %__MODULE__{
    buffer: [String.t()], cursor_line: pos_integer(), cursor_col: pos_integer(),
    scroll_offset: pos_integer(), mode: :insert | :overwrite,
    selection: {pos_integer(), pos_integer(), pos_integer(), pos_integer()} | nil,
    undo_stack: PiTui.UndoStack.t(), kill_ring: PiTui.KillRing.t(),
    tab_width: pos_integer()
  }

  def new(opts \\ []) do
    initial_text = Keyword.get(opts, :text, "")
    lines = String.split(initial_text, "\n", trim: false)

    %__MODULE__{
      buffer: if(lines == [""], do: [], else: lines),
      cursor_line: 0, cursor_col: 0,
      scroll_offset: 0, mode: :insert,
      selection: nil,
      undo_stack: PiTui.UndoStack.new(),
      kill_ring: PiTui.KillRing.new(),
      tab_width: Keyword.get(opts, :tab_width, 2)
    }
  end

  @doc "Current cursor position as {line, col}."
  def cursor(%__MODULE__{cursor_line: l, cursor_col: c}), do: {l, c}

  @doc "Current line content at cursor."
  def current_line(%__MODULE__{buffer: buf, cursor_line: l}) do
    Enum.at(buf, l, "")
  end

  @doc "Inserts text at cursor."
  def insert(%__MODULE__{buffer: buf, cursor_line: l, cursor_col: c} = ed, text) do
    line = Enum.at(buf, l, "")
    new_line = String.slice(line, 0, c) <> text <> String.slice(line, c..-1//1)
    new_buf = List.replace_at(buf, l, new_line)
    save_snapshot(ed, %{ed | buffer: new_buf, cursor_col: c + String.length(text)})
  end

  @doc "Inserts a newline, splitting the current line."
  def insert_newline(%__MODULE__{buffer: buf, cursor_line: l, cursor_col: c} = ed) do
    line = Enum.at(buf, l, "")
    left = String.slice(line, 0, c)
    right = String.slice(line, c..-1//1)
    {before, after_lines} = Enum.split(buf, l)
    new_buf = before ++ [left, right] ++ Enum.drop(after_lines, 1)
    save_snapshot(ed, %{ed | buffer: new_buf, cursor_line: l + 1, cursor_col: 0})
  end

  @doc "Deletes character before cursor."
  def delete_before(%__MODULE__{cursor_line: l, cursor_col: 0} = ed) when l > 0 do
    buf = ed.buffer
    prev_line = Enum.at(buf, l - 1, "")
    cur_line = Enum.at(buf, l, "")
    new_col = String.length(prev_line)
    merged = prev_line <> cur_line
    {before, after_lines} = Enum.split(buf, l - 1)
    new_buf = before ++ [merged] ++ Enum.drop(after_lines, 2)
    save_snapshot(ed, %{ed | buffer: new_buf, cursor_line: l - 1, cursor_col: new_col})
  end

  def delete_before(%__MODULE__{cursor_col: c} = ed) when c > 0 do
    line = current_line(ed)
    new_line = String.slice(line, 0, c - 1) <> String.slice(line, c..-1//1)
    buf = List.replace_at(ed.buffer, ed.cursor_line, new_line)
    save_snapshot(ed, %{ed | buffer: buf, cursor_col: c - 1})
  end

  def delete_before(ed), do: ed

  @doc "Moves cursor up one line."
  def cursor_up(%__MODULE__{cursor_line: 0} = ed), do: ed
  def cursor_up(%__MODULE__{cursor_line: l, cursor_col: c, buffer: buf} = ed) do
    new_col = min(c, String.length(Enum.at(buf, l - 1, "")))
    %{ed | cursor_line: l - 1, cursor_col: new_col}
  end

  @doc "Moves cursor down one line."
  def cursor_down(%__MODULE__{cursor_line: l, buffer: buf} = ed) when l < length(buf) - 1 do
    new_col = min(ed.cursor_col, String.length(Enum.at(buf, l + 1, "")))
    %{ed | cursor_line: l + 1, cursor_col: new_col}
  end
  def cursor_down(ed), do: ed

  @doc "Moves cursor left."
  def cursor_left(%__MODULE__{cursor_line: l, cursor_col: 0} = ed) when l > 0 do
    prev_len = String.length(Enum.at(ed.buffer, l - 1, ""))
    %{ed | cursor_line: l - 1, cursor_col: prev_len}
  end
  def cursor_left(%__MODULE__{cursor_col: c} = ed) when c > 0, do: %{ed | cursor_col: c - 1}
  def cursor_left(ed), do: ed

  @doc "Moves cursor right."
  def cursor_right(%__MODULE__{cursor_line: l, cursor_col: c, buffer: buf} = ed) do
    line_len = String.length(Enum.at(buf, l, ""))
    if c < line_len, do: %{ed | cursor_col: c + 1}, else: ed
  end

  @doc "Moves cursor to start of line."
  def cursor_home(%__MODULE__{} = ed), do: %{ed | cursor_col: 0}

  @doc "Moves cursor to end of line."
  def cursor_end(%__MODULE__{buffer: buf, cursor_line: l} = ed) do
    %{ed | cursor_col: String.length(Enum.at(buf, l, ""))}
  end

  @doc "Deletes from cursor to end of line (kill)."
  def kill_line(%__MODULE__{buffer: buf, cursor_line: l, cursor_col: c} = ed) do
    line = Enum.at(buf, l, "")
    killed = String.slice(line, c..-1//1)
    new_line = String.slice(line, 0, c)
    new_buf = List.replace_at(buf, l, new_line)
    ed = %{ed | buffer: new_buf, kill_ring: PiTui.KillRing.kill(ed.kill_ring, killed)}
    save_snapshot(ed, ed)
  end

  @doc "Yanks (pastes) the most recently killed text at cursor."
  def yank(%__MODULE__{} = ed) do
    {text, kr} = PiTui.KillRing.yank(ed.kill_ring)
    if text, do: insert(%{ed | kill_ring: kr}, text), else: ed
  end

  @doc "Returns the full text content."
  def text(%__MODULE__{buffer: buf}), do: Enum.join(buf, "\n")

  @doc "Renders the editor viewport. Returns {lines, cursor_reposition}."
  def render(%__MODULE__{buffer: buf, cursor_line: l, cursor_col: c, scroll_offset: so} = _ed, height, width) do
    visible = Enum.slice(buf, so, height)
    line_nums = Enum.map(Enum.with_index(visible, so), fn {line, i} ->
      num = PiTui.Terminal.styled(String.pad_leading("#{i + 1}", 4), :dim)
      "#{num}│ #{String.slice(line, 0, width - 6)}"
    end)

    cursor_render = {l - so + 1, c + 6}
    {line_nums, cursor_render}
  end

  defp save_snapshot(%__MODULE__{} = old, %__MODULE__{} = new) do
    %{new | undo_stack: PiTui.UndoStack.record(old.undo_stack, text(old), cursor(old))}
  end
end
