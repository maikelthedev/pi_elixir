defmodule PiTui.KillRingTest do
  use ExUnit.Case, async: true
  test "kill and yank" do
    kr = PiTui.KillRing.new()
    kr = PiTui.KillRing.kill(kr, "hello")
    {text, _} = PiTui.KillRing.yank(kr)
    assert text == "hello"
  end
  test "empty ring returns nil" do
    {nil, _} = PiTui.KillRing.yank(PiTui.KillRing.new())
  end
  test "kill ring has max size" do
    kr = Enum.reduce(1..100, PiTui.KillRing.new(), fn i, acc -> PiTui.KillRing.kill(acc, "item #{i}") end)
    assert length(PiTui.KillRing.entries(kr)) <= 60
  end
end
