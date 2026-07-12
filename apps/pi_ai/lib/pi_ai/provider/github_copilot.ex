defmodule PiAi.Provider.GitHubCopilot do
  @moduledoc "GitHub Copilot API (OpenAI-compatible, requires GitHub token)."
  @behaviour PiAi.Provider
  @api_url "https://api.githubcopilot.com/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "github-copilot")

  @impl true
  def models do
    [
      %PiAi.Model{id: "gpt-4o-copilot", name: "GPT-4o Copilot", provider: "github-copilot", api: "openai-responses", context_window: 128_000, max_tokens: 8192},
      %PiAi.Model{id: "claude-sonnet-copilot", name: "Claude Sonnet Copilot", provider: "github-copilot", api: "openai-responses", context_window: 200_000, max_tokens: 8192}
    ]
  end
end
