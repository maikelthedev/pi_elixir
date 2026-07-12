defmodule PiAi.ModelTest do
  use ExUnit.Case, async: true

  describe "struct" do
    test "constructs a model" do
      model = %PiAi.Model{
        id: "claude-sonnet-4",
        name: "Claude Sonnet 4",
        provider: "anthropic",
        api: "anthropic-messages",
        context_window: 200_000,
        max_tokens: 8192
      }
      assert model.id == "claude-sonnet-4"
      assert model.provider == "anthropic"
    end

    test "has sensible defaults for numeric fields" do
      model = %PiAi.Model{id: "test", name: "Test", provider: "test", api: "test"}
      assert model.context_window == 0
      assert model.max_tokens == 0
      assert model.input_cost == 0.0
      assert model.output_cost == 0.0
      assert model.reasoning == false
    end
  end
end
