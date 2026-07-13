defmodule PiAi.Provider.ZAICodingCN do
  @moduledoc "Z.AI Coding China variant."
  @behaviour PiAi.Provider
  @api_url "https://api.z.ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "zai-coding-cn")

  @impl true
  def models do
    [%PiAi.Model{id: "z-coder-1.5b-cn", name: "Z Coder 1.5B (CN)", provider: "zai-coding-cn", api: "openai-responses", context_window: 4096, max_tokens: 2048}]
  end
end
