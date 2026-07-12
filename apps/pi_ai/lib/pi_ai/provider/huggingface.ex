defmodule PiAi.Provider.HuggingFace do
  @moduledoc "HuggingFace Inference API (OpenAI-compatible)."
  @behaviour PiAi.Provider
  @api_url "https://api-inference.huggingface.co/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts), do: PiAi.Provider.OpenAICompat.stream_chat(@api_url, model, messages, opts, "huggingface")

  @impl true
  def models do
    [
      %PiAi.Model{id: "meta-llama/Llama-3.3-70B-Instruct", name: "Llama 3.3 70B", provider: "huggingface", api: "openai-responses", context_window: 128_000, max_tokens: 4096},
      %PiAi.Model{id: "microsoft/Phi-3.5-mini-instruct", name: "Phi 3.5 Mini", provider: "huggingface", api: "openai-responses", context_window: 128_000, max_tokens: 4096}
    ]
  end
end
