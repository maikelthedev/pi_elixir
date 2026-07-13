defmodule PiAi.Provider.XiaomiTokenPlanCN do
  @moduledoc "Xiaomi Token Plan (China) provider."
  @behaviour PiAi.Provider

  @impl true
  def stream_chat(model, messages, opts) do
    base = System.get_env("XIAOMI_TOKEN_PLAN_CN_URL") || "https://token-plan.api.xiaomi.cn/v1/chat/completions"
    PiAi.Provider.OpenAICompat.stream_chat(base, model, messages, opts, "xiaomi-token-plan-cn")
  end

  @impl true
  def models do
    [%PiAi.Model{id: "mi-token-plan-cn", name: "Mi Token Plan (CN)", provider: "xiaomi-token-plan-cn", api: "openai-responses", context_window: 128_000, max_tokens: 4096}]
  end
end
