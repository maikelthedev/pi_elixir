defmodule PiAi.Providers do
  @moduledoc """
  Central registry of all LLM providers and model lookup.

  Maintains a list of known provider modules and provides
  discovery and model search across all of them.
  """

  @known_providers [
    PiAi.Provider.Anthropic,
    PiAi.Provider.OpenAI,
    PiAi.Provider.Gemini,
    PiAi.Provider.DeepSeek,
    PiAi.Provider.Groq,
    PiAi.Provider.OpenRouter,
    PiAi.Provider.Together,
    PiAi.Provider.Fireworks,
    PiAi.Provider.XAI,
    PiAi.Provider.Mistral,
    PiAi.Provider.Cerebras,
    PiAi.Provider.NVIDIA,
    PiAi.Provider.HuggingFace,
    PiAi.Provider.GitHubCopilot,
    PiAi.Provider.Perplexity,
    PiAi.Provider.AzureOpenAI,
    PiAi.Provider.VercelAIGateway,
    PiAi.Provider.CloudflareWorkersAI,
    PiAi.Provider.Minimax,
    PiAi.Provider.OpenAICodex,
    PiAi.Provider.GoogleVertex,
    PiAi.Provider.MoonshotAI,
    PiAi.Provider.ZAI,
    PiAi.Provider.Xiaomi,
    PiAi.Provider.KimiCoding,
    PiAi.Provider.OpenCode,
    PiAi.Provider.AntLing,
    PiAi.Provider.Bedrock
  ]

  @doc """
  Returns only the loaded provider modules from the known list.
  """
  @spec loaded_providers() :: [module()]
  def loaded_providers do
    Enum.filter(@known_providers, &Code.ensure_loaded?(&1))
  end

  @doc """
  Returns all models from every loaded provider.
  """
  @spec all_models() :: [PiAi.Model.t()]
  def all_models do
    loaded_providers()
    |> Enum.flat_map(fn mod ->
      if function_exported?(mod, :models, 0) do
        apply(mod, :models, [])
      else
        []
      end
    end)
  end

  @doc """
  Finds a model by ID string.
  """
  @spec find_model(String.t()) :: {:ok, PiAi.Model.t()} | {:error, String.t()}
  def find_model(model_id) do
    case Enum.find(all_models(), &(&1.id == model_id)) do
      nil -> {:error, "Model not found: #{model_id}"}
      model -> {:ok, model}
    end
  end
end
