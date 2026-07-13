defmodule PiCodingAgent.Component.ExtensionSelectorTest do
  use ExUnit.Case, async: true
  test "renders extensions" do
    result = PiCodingAgent.Component.ExtensionSelector.render([{"hello", true}, {"world", false}], 0)
    assert Enum.join(result) =~ "hello"
  end
end
