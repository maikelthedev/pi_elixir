defmodule PiAi.Provider.Fireworks do
  @moduledoc "Fireworks.ai API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.fireworks.ai/inference/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "fireworks")

  @impl true
  def models do
    [
      %PiAi.Model{id: "accounts/fireworks/models/llama-v3p3-70b-instruct", name: "Llama 3.3 70B", provider: "fireworks", api: "openai-responses", context_window: 128_000, max_tokens: 8192},
      %PiAi.Model{id: "accounts/fireworks/models/llama-v3p1-405b-instruct", name: "Llama 3.1 405B", provider: "fireworks", api: "openai-responses", context_window: 128_000, max_tokens: 8192},
      %PiAi.Model{id: "accounts/fireworks/models/deepseek-v3", name: "DeepSeek V3", provider: "fireworks", api: "openai-responses", context_window: 64_000, max_tokens: 4096}
    ]
  end
end
