defmodule PiCodingAgent.Component.ExtensionInputTest do
  use ExUnit.Case, async: true
  test "renders label and value" do
    result = PiCodingAgent.Component.ExtensionInput.render("API Key", "sk-xxx", 0)
    assert Enum.join(result) =~ "API Key"
  end
end
