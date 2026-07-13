defmodule PiAi.Provider.MoonshotAICN do
  @moduledoc "Moonshot AI China variant."
  @behaviour PiAi.Provider
  @api_url "https://api.moonshot.cn/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "moonshotai-cn")

  @impl true
  def models do
    [%PiAi.Model{id: "moonshot-v1-128k-cn", name: "Moonshot v1 128K (CN)", provider: "moonshotai-cn", api: "openai-responses", context_window: 128_000, max_tokens: 4096}]
  end
end
