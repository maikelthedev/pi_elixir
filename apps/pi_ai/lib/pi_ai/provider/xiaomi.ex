defmodule PiAi.Provider.Xiaomi do
  @moduledoc "Xiaomi AI API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.minimax.chat/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "xiaomi")

  @impl true
  def models do
    [%PiAi.Model{id: "mi-ai-v1", name: "Mi AI v1", provider: "xiaomi", api: "openai-responses", context_window: 8192, max_tokens: 2048}]
  end
end
