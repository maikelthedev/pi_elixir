defmodule PiAi.Provider.AzureOpenAI do
  @moduledoc "Azure OpenAI API. Uses custom endpoint and key from env/config."
  @behaviour PiAi.Provider

  @impl true
  def stream_chat(model, messages, opts) do
    azure_endpoint = System.get_env("AZURE_OPENAI_ENDPOINT") || "https://your-resource.openai.azure.com"
    api_version = System.get_env("AZURE_OPENAI_API_VERSION") || "2024-08-01-preview"
    api_url = "#{azure_endpoint}/openai/deployments/#{model.id}/chat/completions?api-version=#{api_version}"
    PiAi.Provider.OpenAICompat.stream_chat(api_url, model, messages, opts, "azure-openai")
  end

  @impl true
  def models do
    [
      %PiAi.Model{id: "gpt-4o", name: "GPT-4o (Azure)", provider: "azure-openai", api: "openai-responses", context_window: 128_000, max_tokens: 16_384},
      %PiAi.Model{id: "gpt-4o-mini", name: "GPT-4o Mini (Azure)", provider: "azure-openai", api: "openai-responses", context_window: 128_000, max_tokens: 16_384}
    ]
  end
end
