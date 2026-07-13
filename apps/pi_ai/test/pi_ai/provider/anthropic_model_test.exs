defmodule PiAi.Provider.AnthropicModelTest do
  use ExUnit.Case, async: true
  test "models returns structs with correct fields" do
    models = PiAi.Provider.Anthropic.models()
    assert length(models) > 0
    assert Enum.all?(models, &match?(%PiAi.Model{provider: "anthropic"}, &1))
  end
end
