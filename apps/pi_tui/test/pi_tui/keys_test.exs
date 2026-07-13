defmodule PiTui.KeysTest do
  use ExUnit.Case, async: true
  test "parses arrow keys" do
    assert PiTui.Keys.parse("\e[A") == {:up, ""}
    assert PiTui.Keys.parse("\e[B") == {:down, ""}
    assert PiTui.Keys.parse("\e[C") == {:right, ""}
    assert PiTui.Keys.parse("\e[D") == {:left, ""}
  end
  test "parses ctrl keys" do
    assert PiTui.Keys.parse(<<3>>) == {{:ctrl, ?c}, ""}
    assert PiTui.Keys.parse(<<4>>) == {{:ctrl, ?d}, ""}
  end
  test "parses enter and tab" do
    assert PiTui.Keys.parse("\n") == {:enter, ""}
    assert PiTui.Keys.parse("\t") == {:tab, ""}
  end
  test "name returns readable names" do
    assert PiTui.Keys.name(:up) == "Up"
    assert PiTui.Keys.name(:enter) == "Enter"
    assert PiTui.Keys.name({:ctrl, ?c}) == "C-c"
  end
end
