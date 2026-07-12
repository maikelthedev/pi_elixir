defmodule PiAi.Provider.OpenRouter do
  @moduledoc "OpenRouter unified API (OpenAI-compatible, dozens of models)."
  @behaviour PiAi.Provider
  @api_url "https://openrouter.ai/api/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "openrouter")

  @impl true
  def models do
    [
      %PiAi.Model{id: "openai/gpt-4o", name: "GPT-4o (OpenRouter)", provider: "openrouter", api: "openai-responses", context_window: 128_000, max_tokens: 16_384},
      %PiAi.Model{id: "anthropic/claude-sonnet-4", name: "Claude Sonnet 4 (OpenRouter)", provider: "openrouter", api: "openai-responses", context_window: 200_000, max_tokens: 8192},
      %PiAi.Model{id: "google/gemini-2.5-flash", name: "Gemini 2.5 Flash (OpenRouter)", provider: "openrouter", api: "openai-responses", context_window: 1_000_000, max_tokens: 64_000},
      %PiAi.Model{id: "deepseek/deepseek-chat", name: "DeepSeek V3 (OpenRouter)", provider: "openrouter", api: "openai-responses", context_window: 64_000, max_tokens: 8192}
    ]
  end
end
