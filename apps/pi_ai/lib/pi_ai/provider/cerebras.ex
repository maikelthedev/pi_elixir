defmodule PiAi.Provider.Cerebras do
  @moduledoc "Cerebras API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.cerebras.ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "cerebras")

  @impl true
  def models do
    [
      %PiAi.Model{id: "llama3.1-8b", name: "Llama 3.1 8B", provider: "cerebras", api: "openai-responses", context_window: 8192, max_tokens: 4096},
      %PiAi.Model{id: "llama3.1-70b", name: "Llama 3.1 70B", provider: "cerebras", api: "openai-responses", context_window: 8192, max_tokens: 4096}
    ]
  end
end
