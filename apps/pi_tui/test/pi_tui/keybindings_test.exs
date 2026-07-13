defmodule PiTui.KeybindingsTest do
  use ExUnit.Case, async: true
  test "resolve returns action for key" do
    kb = PiTui.Keybindings.new()
    assert PiTui.Keybindings.resolve(kb, :enter) == :submit
    assert PiTui.Keybindings.resolve(kb, {:ctrl, ?c}) == :quit
  end
  test "resolve returns :char for unknown key" do
    kb = PiTui.Keybindings.new()
    assert PiTui.Keybindings.resolve(kb, {:func, 99}) == :char
  end
  test "rebind changes binding" do
    kb = PiTui.Keybindings.new()
    kb = PiTui.Keybindings.rebind(kb, :enter, :newline)
    assert PiTui.Keybindings.resolve(kb, :enter) == :newline
  end
end
