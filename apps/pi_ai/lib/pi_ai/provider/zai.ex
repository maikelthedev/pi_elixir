defmodule PiAi.Provider.ZAI do
  @moduledoc "Z.AI (Chinese provider, OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.z.ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "zai")

  @impl true
  def models do
    [
      %PiAi.Model{id: "z-1.7b", name: "Z 1.7B", provider: "zai", api: "openai-responses", context_window: 4096, max_tokens: 2048}
    ]
  end
end
