defmodule PiAi.Provider.Together do
  @moduledoc "Together.ai API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.together.xyz/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "together")

  @impl true
  def models do
    [
      %PiAi.Model{id: "mistralai/Mixtral-8x22B-Instruct-v0.1", name: "Mixtral 8x22B", provider: "together", api: "openai-responses", context_window: 65_536, max_tokens: 4096},
      %PiAi.Model{id: "meta-llama/Llama-3.3-70B-Instruct-Turbo", name: "Llama 3.3 70B", provider: "together", api: "openai-responses", context_window: 128_000, max_tokens: 4096},
      %PiAi.Model{id: "deepseek-ai/DeepSeek-V3", name: "DeepSeek V3", provider: "together", api: "openai-responses", context_window: 64_000, max_tokens: 4096}
    ]
  end
end
