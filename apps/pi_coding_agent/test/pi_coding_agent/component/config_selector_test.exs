defmodule PiCodingAgent.Component.ConfigSelectorTest do
  use ExUnit.Case, async: true
  test "renders config items" do
    items = [{"key", "val", "default"}]
    result = PiCodingAgent.Component.ConfigSelector.render(items, 0)
    assert Enum.join(result) =~ "key"
  end
end
