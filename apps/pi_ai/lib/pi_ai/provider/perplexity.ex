defmodule PiAi.Provider.Perplexity do
  @moduledoc "Perplexity AI API (OpenAI-compatible, web-search augmented)."
  @behaviour PiAi.Provider
  @api_url "https://api.perplexity.ai/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "perplexity")

  @impl true
  def models do
    [
      %PiAi.Model{id: "sonar-pro", name: "Sonar Pro", provider: "perplexity", api: "openai-responses", context_window: 200_000, max_tokens: 4096},
      %PiAi.Model{id: "sonar", name: "Sonar", provider: "perplexity", api: "openai-responses", context_window: 127_000, max_tokens: 4096}
    ]
  end
end
