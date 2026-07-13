defmodule PiCodingAgent.Component.TreeSelectorTest do
  use ExUnit.Case, async: true
  test "renders branches" do
    assert length(PiCodingAgent.Component.TreeSelector.render(["main", "feature"], 0)) > 0
  end
end
