defmodule PiTui.UtilsTest do
  use ExUnit.Case, async: true
  test "terminal_size returns tuple" do
    {r, c} = PiTui.Utils.terminal_size()
    assert is_integer(r) and r > 0
    assert is_integer(c) and c > 0
  end
  test "chunk splits list" do
    assert PiTui.Utils.chunk([1,2,3,4,5], 2) == [[1,2], [3,4], [5]]
  end
  test "clamp constrains values" do
    assert PiTui.Utils.clamp(5, 0, 10) == 5
    assert PiTui.Utils.clamp(-1, 0, 10) == 0
    assert PiTui.Utils.clamp(20, 0, 10) == 10
  end
  test "unique_id returns string" do
    assert is_binary(PiTui.Utils.unique_id())
  end
end
