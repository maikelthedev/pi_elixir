defmodule PiTui.UndoStackTest do
  use ExUnit.Case, async: true
  test "record and undo" do
    us = PiTui.UndoStack.new()
    us = PiTui.UndoStack.record(us, "hello", 5)
    {us, text, cursor} = PiTui.UndoStack.undo(us)
    assert text == "hello"
    assert cursor == 5
  end
  test "undo from empty stack" do
    {_us, nil, nil} = PiTui.UndoStack.undo(PiTui.UndoStack.new())
  end
  test "redo after undo" do
    us = PiTui.UndoStack.new() |> PiTui.UndoStack.record("v1", 2) |> PiTui.UndoStack.record("v2", 3)
    {us, _t, _c} = PiTui.UndoStack.undo(us)
    {_us, text, _c} = PiTui.UndoStack.redo(us)
    assert text == "v2"
  end
end
