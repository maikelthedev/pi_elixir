defmodule PiAi.Provider.KimiCoding do
  @moduledoc "Kimi Coding API (Chinese provider, OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.kimi.ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "kimi-coding")

  @impl true
  def models do
    [%PiAi.Model{id: "kimi-coding-v1", name: "Kimi Coding v1", provider: "kimi-coding", api: "openai-responses", context_window: 128_000, max_tokens: 4096}]
  end
end
