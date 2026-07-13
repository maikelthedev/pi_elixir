defmodule PiCodingAgent.Core.ProviderAttribution do
  @moduledoc "Provider attribution and display for messages."

  def attributions do
    %{
      "anthropic" => %{name: "Anthropic", color: :orange, url: "https://anthropic.com"},
      "openai" => %{name: "OpenAI", color: :green, url: "https://openai.com"},
      "google" => %{name: "Google", color: :blue, url: "https://google.com"},
      "gemini" => %{name: "Google Gemini", color: :blue, url: "https://google.com"},
      "deepseek" => %{name: "DeepSeek", color: :cyan, url: "https://deepseek.com"},
      "groq" => %{name: "Groq", color: :magenta, url: "https://groq.com"},
      "mistral" => %{name: "Mistral", color: :yellow, url: "https://mistral.ai"},
      "openrouter" => %{name: "OpenRouter", color: :white, url: "https://openrouter.ai"},
      "together" => %{name: "Together", color: :green, url: "https://together.ai"},
      "xai" => %{name: "xAI", color: :red, url: "https://x.ai"},
      "nvidia" => %{name: "NVIDIA", color: :green, url: "https://nvidia.com"},
      "cerebras" => %{name: "Cerebras", color: :blue, url: "https://cerebras.ai"},
      "huggingface" => %{name: "HuggingFace", color: :yellow, url: "https://huggingface.co"},
      "fireworks" => %{name: "Fireworks", color: :red, url: "https://fireworks.ai"},
      "perplexity" => %{name: "Perplexity", color: :cyan, url: "https://perplexity.ai"},
      "bedrock" => %{name: "AWS Bedrock", color: :orange, url: "https://aws.amazon.com/bedrock"},
      "vertex" => %{name: "Google Vertex", color: :blue, url: "https://cloud.google.com/vertex-ai"}
    }
  end

  def get(provider) do
    Map.get(attributions(), provider, %{name: provider, color: :white, url: nil})
  end

  def display_name(provider), do: get(provider).name
  def color(provider), do: get(provider).color
  def url(provider), do: get(provider).url
end
