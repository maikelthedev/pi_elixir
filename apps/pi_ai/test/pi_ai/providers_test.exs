defmodule PiAi.ProvidersTest do
  use ExUnit.Case, async: true

  describe "loaded_providers/0" do
    test "returns at least 6 providers" do
      providers = PiAi.Providers.loaded_providers()
      assert length(providers) >= 6
    end
  end

  describe "all_models/0" do
    test "returns models across all providers" do
      models = PiAi.Providers.all_models()
      assert length(models) > 5
      assert Enum.all?(models, &match?(%PiAi.Model{}, &1))
    end
  end

  describe "find_model/1" do
    test "finds a known model" do
      assert {:ok, model} = PiAi.Providers.find_model("gpt-4o")
      assert model.id == "gpt-4o" or model.id == "openai/gpt-4o"
    end

    test "returns error for unknown model" do
      assert {:error, _} = PiAi.Providers.find_model("nonexistent-model-xyz")
    end
  end
end
