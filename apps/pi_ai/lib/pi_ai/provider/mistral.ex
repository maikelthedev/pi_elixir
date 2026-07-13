defmodule PiAi.Provider.Mistral do
  @moduledoc "Mistral AI API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.mistral.ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "mistral")

  @impl true
  def models do
    [
      %PiAi.Model{id: "mistral-large-latest", name: "Mistral Large Latest", provider: "mistral", api: "openai-responses", context_window: 128_000, max_tokens: 8192, input_cost: 2.0, output_cost: 6.0},
      %PiAi.Model{id: "mistral-small-latest", name: "Mistral Small Latest", provider: "mistral", api: "openai-responses", context_window: 32_000, max_tokens: 4096, input_cost: 0.2, output_cost: 0.6},
      %PiAi.Model{id: "codestral-latest", name: "Codestral Latest", provider: "mistral", api: "openai-responses", context_window: 256_000, max_tokens: 8192}
    ]
  end
end
