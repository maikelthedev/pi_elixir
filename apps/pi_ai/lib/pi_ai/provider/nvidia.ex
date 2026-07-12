defmodule PiAi.Provider.NVIDIA do
  @moduledoc "NVIDIA NIM API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://integrate.api.nvidia.com/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "nvidia")

  @impl true
  def models do
    [
      %PiAi.Model{id: "meta/llama-3.3-70b-instruct", name: "Llama 3.3 70B", provider: "nvidia", api: "openai-responses", context_window: 128_000, max_tokens: 4096},
      %PiAi.Model{id: "mistralai/mistral-large", name: "Mistral Large", provider: "nvidia", api: "openai-responses", context_window: 128_000, max_tokens: 4096}
    ]
  end
end
