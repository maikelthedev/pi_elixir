defmodule PiAi.Provider.XAI do
  @moduledoc "xAI (Grok) API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.x.ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "xai")

  @impl true
  def models do
    [
      %PiAi.Model{id: "grok-3", name: "Grok 3", provider: "xai", api: "openai-responses", context_window: 131_072, max_tokens: 8192},
      %PiAi.Model{id: "grok-3-mini", name: "Grok 3 Mini", provider: "xai", api: "openai-responses", context_window: 131_072, max_tokens: 8192}
    ]
  end
end
