defmodule PiAi.Provider.CloudflareAIGateway do
  @moduledoc "Cloudflare AI Gateway (proxy routing through Cloudflare)."
  @behaviour PiAi.Provider

  @impl true
  def stream_chat(model, messages, opts) do
    gateway_url = System.get_env("CLOUDFLARE_AI_GATEWAY_URL")
    account_id = System.get_env("CLOUDFLARE_ACCOUNT_ID")

    base =
      cond do
        gateway_url -> gateway_url
        account_id -> "https://gateway.ai.cloudflare.com/v1/#{account_id}/default"
        true -> "https://gateway.ai.cloudflare.com/v1"
      end

    api_url = "#{base}/#{model.provider}/#{model.id}"
    PiAi.Provider.OpenAICompat.stream_chat(api_url, model, messages, opts, "cloudflare-ai-gateway")
  end

  @impl true
  def models do
    [
      %PiAi.Model{id: "gpt-4o", name: "GPT-4o (CF Gateway)", provider: "cloudflare-ai-gateway", api: "openai-responses"},
      %PiAi.Model{id: "claude-sonnet-4", name: "Claude Sonnet 4 (CF Gateway)", provider: "cloudflare-ai-gateway", api: "openai-responses"}
    ]
  end
end
