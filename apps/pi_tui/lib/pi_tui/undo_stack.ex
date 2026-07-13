defmodule PiTui.UndoStack do
  @moduledoc "Undo/redo stack for editor operations."

  defstruct [:undo_stack, :redo_stack, max_depth: 50]

  @type t :: %__MODULE__{
    undo_stack: [{String.t(), pos_integer()}],
    redo_stack: [{String.t(), pos_integer()}],
    max_depth: pos_integer()
  }

  def new(opts \\ []), do: %__MODULE__{
    undo_stack: [],
    redo_stack: [],
    max_depth: Keyword.get(opts, :max_depth, 50)
  }

  def record(%__MODULE__{undo_stack: stack, max_depth: max} = us, text, cursor) do
    %{us | undo_stack: [{text, cursor} | stack] |> Enum.take(max), redo_stack: []}
  end

  def undo(%__MODULE__{undo_stack: []} = us), do: {us, nil, nil}
  def undo(%__MODULE__{undo_stack: [entry | rest], redo_stack: redo} = us) do
    {text, cursor} = entry
    {%{us | undo_stack: rest, redo_stack: [entry | redo]}, text, cursor}
  end

  def redo(%__MODULE__{redo_stack: []} = us), do: {us, nil, nil}
  def redo(%__MODULE__{redo_stack: [entry | rest], undo_stack: undo} = us) do
    {text, cursor} = entry
    {%{us | redo_stack: rest, undo_stack: [entry | undo]}, text, cursor}
  end

  def clear(%__MODULE__{} = us), do: %{us | undo_stack: [], redo_stack: []}
end
