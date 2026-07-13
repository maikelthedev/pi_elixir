defmodule PiAi.ProvidersIntegrationTest do
  use ExUnit.Case, async: true
  test "find_model finds all providers" do
    {:ok, model} = PiAi.Providers.find_model("gpt-4o")
    assert model.id == "gpt-4o" or model.id == "openai/gpt-4o"
  end
  test "all_models returns across all providers" do
    assert length(PiAi.Providers.all_models()) > 10
  end
end
