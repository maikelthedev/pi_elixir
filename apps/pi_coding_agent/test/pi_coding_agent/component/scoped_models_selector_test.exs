defmodule PiCodingAgent.Component.ScopedModelsSelectorTest do
  use ExUnit.Case, async: true
  test "renders models" do
    all = [%PiAi.Model{id: "a", name: "A", provider: "p", api: "t"}]
    scoped = [%PiAi.Model{id: "b", name: "B", provider: "p", api: "t"}]
    result = PiCodingAgent.Component.ScopedModelsSelector.render(scoped, all, 0)
    assert Enum.join(result) =~ "b"
  end
end
