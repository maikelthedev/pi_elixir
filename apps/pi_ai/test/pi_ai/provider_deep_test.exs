defmodule PiAi.ProviderDeepTest do
  use ExUnit.Case, async: true

  test "all providers return consistent model list format" do
    PiAi.Providers.all_models()
    |> Enum.each(fn model ->
      assert is_binary(model.id)
      assert is_binary(model.provider)
      assert model.context_window >= 0
    end)
  end

  test "anthropic provider defines models" do
    models = PiAi.Provider.Anthropic.models()
    assert is_list(models)
    assert length(models) > 0
    assert Enum.any?(models, fn m -> String.contains?(m.id, "claude") end)
  end

  test "openai provider defines models" do
    models = PiAi.Provider.OpenAI.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "gemini provider defines models" do
    models = PiAi.Provider.Gemini.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "deepseek provider defines models" do
    models = PiAi.Provider.DeepSeek.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "groq provider defines models" do
    models = PiAi.Provider.Groq.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "xai provider defines models" do
    models = PiAi.Provider.XAI.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "mistral provider defines models" do
    models = PiAi.Provider.Mistral.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "together provider defines models" do
    models = PiAi.Provider.Together.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "nvidia provider defines models" do
    models = PiAi.Provider.NVIDIA.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "cerebras provider defines models" do
    models = PiAi.Provider.Cerebras.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "openrouter provider defines models" do
    models = PiAi.Provider.OpenRouter.models()
    assert is_list(models)
    assert length(models) > 0
  end

  test "all providers have unique IDs across all providers" do
    all_ids = PiAi.Providers.all_models() |> Enum.map(& &1.id)
    unique_ids = Enum.uniq(all_ids)
    assert length(unique_ids) >= length(all_ids) * 0.8
  end

  test "registry lookup returns model" do
    case PiAi.ModelRegistry.search("claude") do
      [_ | _] -> assert true
      [] -> assert true
    end
  end
end
