defmodule PiCodingAgent.Mode.Print do
  @moduledoc "Print mode — one-shot prompt/response with demo fallback."
  alias PiAi.Message

  @spec run([Message.t()], keyword()) :: {:ok, [Message.t()]} | {:error, String.t()}
  def run(messages, opts) do
    model = Keyword.fetch!(opts, :model)
    prompt = Enum.map_join(messages, "\n", &(&1.content || ""))

    result = try do
      case model.api do
        "anthropic-messages" -> PiAi.Provider.Anthropic.stream_chat(model, messages, opts)
        "openai-responses" -> PiAi.Provider.OpenAI.stream_chat(model, messages, opts)
        "google-generative-ai" -> PiAi.Provider.Gemini.stream_chat(model, messages, opts)
        _ -> PiAi.Provider.OpenAICompat.stream_chat("https://api.openai.com/v1/chat/completions", model, messages, [stream: false], model.provider)
      end
    rescue
      e -> {:error, "HTTP error: #{inspect(e)}"}
    catch
      :exit, e -> {:error, "Exit: #{inspect(e)}"}
    end

    case result do
      {:ok, [response]} ->
        text = response["content"] || response[:content] || ""
        IO.puts(text)
        {:ok, messages ++ [%Message{role: :assistant, content: text}]}

      {:error, reason} ->
        IO.puts("\n[#{PiTui.Terminal.styled("demo", :yellow)}] No response from #{model.id}")
        IO.puts("  #{reason}")
        IO.puts("  Configure auth via /login or set environment variable.")
        IO.puts("\nYour prompt: #{prompt}")
        {:ok, messages}
    end
  end
end
