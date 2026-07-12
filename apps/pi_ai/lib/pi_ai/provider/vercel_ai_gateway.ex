defmodule PiAi.Provider.VercelAIGateway do
  @moduledoc "Vercel AI Gateway (OpenAI-compatible proxy)."
  @behaviour PiAi.Provider

  @impl true
  def stream_chat(model, messages, opts) do
    base = System.get_env("VERCEL_AI_GATEWAY_URL") || "https://gateway.ai.vercel.sh/v1/chat/completions"
    PiAi.Provider.OpenAICompat.stream_chat(base, model, messages, opts, "vercel-ai-gateway")
  end

  @impl true
  def models do
    [%PiAi.Model{id: "default", name: "Default (configured on Vercel)", provider: "vercel-ai-gateway", api: "openai-responses", context_window: 128_000, max_tokens: 4096}]
  end
end
