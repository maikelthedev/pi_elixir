defmodule PiAi.Provider.Minimax do
  @moduledoc "MiniMax AI API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.minimax.chat/v1/text/chatcompletion_v2"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "minimax")

  @impl true
  def models do
    [%PiAi.Model{id: "MiniMax-Text-01", name: "MiniMax Text-01", provider: "minimax", api: "openai-responses", context_window: 1_000_000, max_tokens: 4096}]
  end
end
