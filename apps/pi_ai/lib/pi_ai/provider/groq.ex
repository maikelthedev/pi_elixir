defmodule PiAi.Provider.Groq do
  @moduledoc "Groq API (OpenAI-compatible, ultra-fast inference)."
  @behaviour PiAi.Provider
  @api_url "https://api.groq.com/openai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "groq")

  @impl true
  def models do
    [
      %PiAi.Model{id: "llama-3.3-70b-versatile", name: "Llama 3.3 70B", provider: "groq", api: "openai-responses", context_window: 128_000, max_tokens: 32_768, input_cost: 0.59, output_cost: 0.79},
      %PiAi.Model{id: "mixtral-8x7b-32768", name: "Mixtral 8x7B", provider: "groq", api: "openai-responses", context_window: 32_768, max_tokens: 4096},
      %PiAi.Model{id: "gemma2-9b-it", name: "Gemma 2 9B", provider: "groq", api: "openai-responses", context_window: 8192, max_tokens: 4096}
    ]
  end
end
