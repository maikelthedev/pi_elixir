defmodule PiAi.Provider.DeepSeek do
  @moduledoc "DeepSeek API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.deepseek.com/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "deepseek")

  @impl true
  def models do
    [
      %PiAi.Model{id: "deepseek-chat", name: "DeepSeek V3", provider: "deepseek", api: "openai-responses", context_window: 64_000, max_tokens: 8192, input_cost: 0.27, output_cost: 1.10},
      %PiAi.Model{id: "deepseek-reasoner", name: "DeepSeek R1", provider: "deepseek", api: "openai-responses", context_window: 64_000, max_tokens: 8192, reasoning: true, input_cost: 0.55, output_cost: 2.19}
    ]
  end
end
