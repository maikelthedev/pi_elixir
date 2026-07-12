defmodule PiAi.Provider.MoonshotAI do
  @moduledoc "Moonshot AI API (Chinese provider, OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.moonshot.cn/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "moonshotai")

  @impl true
  def models do
    [
      %PiAi.Model{id: "moonshot-v1-8k", name: "Moonshot v1 8K", provider: "moonshotai", api: "openai-responses", context_window: 8192, max_tokens: 2048},
      %PiAi.Model{id: "moonshot-v1-32k", name: "Moonshot v1 32K", provider: "moonshotai", api: "openai-responses", context_window: 32_768, max_tokens: 4096},
      %PiAi.Model{id: "moonshot-v1-128k", name: "Moonshot v1 128K", provider: "moonshotai", api: "openai-responses", context_window: 128_000, max_tokens: 4096}
    ]
  end
end
