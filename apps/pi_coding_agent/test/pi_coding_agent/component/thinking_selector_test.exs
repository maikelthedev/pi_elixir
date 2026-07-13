defmodule PiCodingAgent.Component.ThinkingSelectorTest do
  use ExUnit.Case, async: true
  test "renders levels" do
    result = PiCodingAgent.Component.ThinkingSelector.render(2)
    assert Enum.join(result) =~ "medium"
  end
  test "levels list" do
    assert PiCodingAgent.Component.ThinkingSelector.levels() == ~w(off low medium high max)
  end
end
