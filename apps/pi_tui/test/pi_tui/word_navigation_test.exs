defmodule PiTui.WordNavigationTest do
  use ExUnit.Case, async: true
  test "backward returns a valid position" do
    result = PiTui.WordNavigation.backward("hello world", 6)
    assert is_integer(result)
    assert result in 0..10
  end
  test "forward returns a valid position" do
    result = PiTui.WordNavigation.forward("hello world", 0)
    assert is_integer(result)
    assert result in 0..11
  end
  test "delete_backward_word returns tuple" do
    {_text, pos} = PiTui.WordNavigation.delete_backward_word("hello world", 6)
    assert is_integer(pos)
  end
end
