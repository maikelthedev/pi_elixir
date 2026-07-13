defmodule PiCodingAgent.Component.ModelSelectorTest do
  use ExUnit.Case, async: true
  test "renders model list" do
    models = [%PiAi.Model{id: "gpt-4o", name: "GPT-4o", provider: "openai", api: "test"}]
    result = PiCodingAgent.Component.ModelSelector.render(models, 0, "")
    assert Enum.join(result) =~ "gpt-4o"
  end
end
