defmodule PiAi.Provider.CloudflareWorkersAI do
  @moduledoc "Cloudflare Workers AI (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api.cloudflare.com/client/v4/accounts/:account_id/ai/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "cloudflare-workers-ai")

  @impl true
  def models do
    [%PiAi.Model{id: "@cf/meta/llama-3.3-70b-instruct", name: "Llama 3.3 70B", provider: "cloudflare-workers-ai", api: "openai-responses", context_window: 128_000, max_tokens: 4096}]
  end
end
