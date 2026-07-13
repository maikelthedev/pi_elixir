defmodule PiAi.Utils.ProviderEnv do
  @moduledoc "Provider environment resolution - determines which provider to use based on env vars."
  @provider_envs %{
    "ANTHROPIC_API_KEY" => "anthropic",
    "OPENAI_API_KEY" => "openai",
    "GEMINI_API_KEY" => "gemini",
    "GOOGLE_API_KEY" => "gemini",
    "DEEPSEEK_API_KEY" => "deepseek",
    "GROQ_API_KEY" => "groq",
    "TOGETHER_API_KEY" => "together",
    "FIREWORKS_API_KEY" => "fireworks",
    "XAI_API_KEY" => "xai",
    "MISTRAL_API_KEY" => "mistral",
    "NVIDIA_API_KEY" => "nvidia",
    "CEREBRAS_API_KEY" => "cerebras",
    "HUGGINGFACE_API_KEY" => "huggingface",
    "OPENROUTER_API_KEY" => "openrouter",
    "PERPLEXITY_API_KEY" => "perplexity"
  }

  def detect_providers do
    @provider_envs
    |> Enum.filter(fn {env_var, _} -> System.get_env(env_var) != nil end)
    |> Enum.map(fn {_, provider} -> provider end)
    |> Enum.uniq()
  end

  def default_provider do
    case detect_providers() do
      [first | _] -> first
      [] -> "anthropic"
    end
  end

  def has_provider?(provider) do
    Enum.any?(@provider_envs, fn {env_var, p} -> p == provider and System.get_env(env_var) != nil end)
  end

  def api_key(provider) do
    @provider_envs
    |> Enum.find(fn {_, p} -> p == provider end)
    |> case do
      {env_var, _} -> System.get_env(env_var)
      nil -> nil
    end
  end
end
