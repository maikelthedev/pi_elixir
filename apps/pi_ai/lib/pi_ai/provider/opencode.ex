defmodule PiAi.Provider.OpenCode do
  @moduledoc "OpenCode API (for coding models)."
  @behaviour PiAi.Provider
  @api_url "https://api.opencode.ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "opencode")

  @impl true
  def models do
    [%PiAi.Model{id: "opencode-v1", name: "OpenCode v1", provider: "opencode", api: "openai-responses", context_window: 128_000, max_tokens: 4096}]
  end
end
