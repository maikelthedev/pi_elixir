defmodule PiAi.Provider.ConfigValidationTest do
  use ExUnit.Case, async: true
  test "all providers have non-empty model lists" do
    providers = PiAi.Providers.loaded_providers()
    empty = Enum.filter(providers, fn mod ->
      if function_exported?(mod, :models, 0) do
        apply(mod, :models, []) == []
      else
        true
      end
    end)
    assert empty == [], "Providers with empty model lists: #{inspect(empty)}"
  end
  test "all models have required fields" do
    models = PiAi.Providers.all_models()
    invalid = Enum.filter(models, fn m ->
      is_nil(m.id) or is_nil(m.provider) or is_nil(m.api) or
      m.context_window == nil or m.max_tokens == nil
    end)
    assert invalid == [], "Models missing required fields: #{inspect(invalid)}"
  end
  test "provider models have matching api fields" do
    models = PiAi.Providers.all_models()
    valid_apis = ~w(openai-responses anthropic-messages google-generative-ai bedrock-converse-stream openai-completions)
    invalid = Enum.filter(models, fn m ->
      m.api not in valid_apis and not String.starts_with?(m.api, "openai-")
    end)
    assert invalid == [], "Models with unknown api types: #{inspect(Enum.map(invalid, &{&1.id, &1.api}))}"
  end
end
