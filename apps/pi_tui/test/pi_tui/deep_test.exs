defmodule PiTui.DeepTest do
  use ExUnit.Case, async: true

  test "all TUI components compile" do
    components = [
      PiTui.Component.Autocomplete,
      PiTui.Component.Box,
      PiTui.Component.CancellableLoader,
      PiTui.Component.Editor,
      PiTui.Component.Footer,
      PiTui.Component.Input,
      PiTui.Component.Loader,
      PiTui.Component.Markdown,
      PiTui.Component.SelectList,
      PiTui.Component.SettingsList,
      PiTui.Component.Spacer,
      PiTui.Component.Text,
      PiTui.Component.TruncatedText
    ]
    Enum.each(components, fn comp ->
      assert is_atom(comp)
      fns = comp.__info__(:functions) |> Enum.map(&elem(&1, 0))
      assert length(fns) > 0
    end)
  end

  test "terminal colors work" do
    assert is_binary(PiTui.TerminalColors.fg(1))
    assert is_binary(PiTui.TerminalColors.bg(1))
  end

  test "terminal helpers work" do
    assert is_binary(PiTui.Terminal.clear_screen())
    assert is_binary(PiTui.Terminal.hide_cursor)
    assert is_binary(PiTui.Terminal.show_cursor)
  end

  test "keybindings work" do
    kb = PiTui.Keybindings.new()
    assert is_struct(kb)
  end

  test "kill ring operations" do
    kr = PiTui.KillRing.new()
    kr = PiTui.KillRing.kill(kr, "hello")
    assert {_text, _kr} = PiTui.KillRing.yank(kr)
  end

  test "undo stack operations" do
    us = PiTui.UndoStack.new()
    us = PiTui.UndoStack.record(us, "state1", 0)
    us = PiTui.UndoStack.record(us, "state2", 0)
    {us, text, _cursor} = PiTui.UndoStack.undo(us)
    assert text == "state2"
    {us, text, _cursor} = PiTui.UndoStack.undo(us)
    assert text == "state1"
    {us, text, _cursor} = PiTui.UndoStack.redo(us)
    assert text == "state1"
    {us, text, _cursor} = PiTui.UndoStack.redo(us)
    assert text == "state2"
  end

  test "undo on empty stack returns nil" do
    us = PiTui.UndoStack.new()
    {_, text, _} = PiTui.UndoStack.undo(us)
    assert text == nil
  end

  test "redo on empty stack returns nil" do
    us = PiTui.UndoStack.new()
    {_, text, _} = PiTui.UndoStack.redo(us)
    assert text == nil
  end

  test "fuzzy matching" do
    matches = PiTui.Fuzzy.filter("abc", ["aardvark", "abc", "abcdef", "xyz"])
    assert length(matches) >= 2
  end

  test "word navigation" do
    assert PiTui.WordNavigation.backward("hello world", 6) >= 0
    assert PiTui.WordNavigation.forward("hello world", 0) >= 0
  end

  test "stdin buffer collects input" do
    buf = PiTui.StdinBuffer.new()
    assert buf.buffer == ""
  end
end
