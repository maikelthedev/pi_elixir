defmodule PiCodingAgent.Mode.Print do
  @moduledoc "Print mode — one-shot prompt/response."
  alias PiAi.Message

  @spec run([Message.t()], keyword()) :: {:ok, [Message.t()]} | {:error, String.t()}
  def run(messages, opts) do
    model = Keyword.fetch!(opts, :model)
    prompt = Enum.map_join(messages, "\n", &(&1.content || ""))

    result = call_provider(model, messages, opts)

    case result do
      {:ok, [response]} ->
        text = response["content"] || response[:content] || ""
        IO.puts(text)
        {:ok, messages ++ [%Message{role: :assistant, content: text}]}

      {:error, reason} ->
        IO.puts("\n[#{PiTui.Terminal.styled("demo", :yellow)}] No response from #{model.provider} (#{model.id}): #{reason}")
        IO.puts("  Set #{String.upcase(model.provider)}_API_KEY or configure auth.")
        IO.puts("\nYour prompt: #{prompt}")
        {:error, reason}
    end
  end

  defp call_provider(model, messages, opts) do
    case model.provider do
      "anthropic" -> PiAi.Provider.Anthropic.stream_chat(model, messages, opts)
      "openai" -> PiAi.Provider.OpenAI.stream_chat(model, messages, opts)
      "google" -> PiAi.Provider.Gemini.stream_chat(model, messages, opts)
      "deepseek" -> PiAi.Provider.DeepSeek.stream_chat(model, messages, opts)
      "groq" -> PiAi.Provider.Groq.stream_chat(model, messages, opts)
      "openrouter" -> PiAi.Provider.OpenRouter.stream_chat(model, messages, opts)
      "together" -> PiAi.Provider.Together.stream_chat(model, messages, opts)
      "fireworks" -> PiAi.Provider.Fireworks.stream_chat(model, messages, opts)
      "xai" -> PiAi.Provider.XAI.stream_chat(model, messages, opts)
      "mistral" -> PiAi.Provider.Mistral.stream_chat(model, messages, opts)
      "cerebras" -> PiAi.Provider.Cerebras.stream_chat(model, messages, opts)
      "nvidia" -> PiAi.Provider.NVIDIA.stream_chat(model, messages, opts)
      "huggingface" -> PiAi.Provider.HuggingFace.stream_chat(model, messages, opts)
      "github-copilot" -> PiAi.Provider.GitHubCopilot.stream_chat(model, messages, opts)
      "perplexity" -> PiAi.Provider.Perplexity.stream_chat(model, messages, opts)
      "azure-openai" -> PiAi.Provider.AzureOpenAI.stream_chat(model, messages, opts)
      "amazon-bedrock" -> PiAi.Provider.Bedrock.stream_chat(model, messages, opts)
      "vercel-ai-gateway" -> PiAi.Provider.VercelAIGateway.stream_chat(model, messages, opts)
      "cloudflare-workers-ai" -> PiAi.Provider.CloudflareWorkersAI.stream_chat(model, messages, opts)
      "minimax" -> PiAi.Provider.Minimax.stream_chat(model, messages, opts)
      "moonshotai" -> PiAi.Provider.MoonshotAI.stream_chat(model, messages, opts)
      "zai" -> PiAi.Provider.ZAI.stream_chat(model, messages, opts)
      "zai-coding-cn" -> PiAi.Provider.ZAICodingCN.stream_chat(model, messages, opts)
      "xiaomi" -> PiAi.Provider.Xiaomi.stream_chat(model, messages, opts)
      "kimi-coding" -> PiAi.Provider.KimiCoding.stream_chat(model, messages, opts)
      "opencode" -> PiAi.Provider.OpenCode.stream_chat(model, messages, opts)
      "ant-ling" -> PiAi.Provider.AntLing.stream_chat(model, messages, opts)
      "openai-codex" -> PiAi.Provider.OpenAICodex.stream_chat(model, messages, opts)
      "google-vertex" -> PiAi.Provider.GoogleVertex.stream_chat(model, messages, opts)
      _ -> {:error, "Unknown provider: #{model.provider}"}
    end
  end
end
