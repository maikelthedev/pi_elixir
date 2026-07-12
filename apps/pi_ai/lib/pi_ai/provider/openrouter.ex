defmodule PiAi.Provider.OpenRouter do
  @moduledoc """
  Provider implementation for OpenRouter's unified API (OpenAI-compatible).

  OpenRouter provides access to dozens of models through a single API.
  """
  @behaviour PiAi.Provider

  @api_url "https://openrouter.ai/api/v1/chat/completions"

  @impl true
  def stream_chat(model, messages, opts) do
    body = %{
      model: model.id,
      max_tokens: Keyword.get(opts, :max_tokens, 4096),
      messages: Enum.map(messages, &PiAi.Provider.OpenAI.message_to_openai/1),
      stream: true
    }

    api_key = resolve_api_key(opts)

    request =
      Req.new(
        url: @api_url,
        method: :post,
        headers: [
          {"authorization", "Bearer #{api_key}"},
          {"content-type", "application/json"},
          {"http-user-agent", "pi-coding-agent/0.1.0"}
        ],
        json: body,
        into: fn chunk, acc -> {:cont, chunk <> (acc || "")} end
      )

    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        response = PiAi.EventStream.accumulate([body])
        {:ok, [response]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "OpenRouter error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def models do
    [
      %PiAi.Model{
        id: "openai/gpt-4o",
        name: "GPT-4o (OpenRouter)",
        provider: "openrouter",
        api: "openai-responses",
        context_window: 128_000,
        max_tokens: 16_384
      },
      %PiAi.Model{
        id: "anthropic/claude-sonnet-4",
        name: "Claude Sonnet 4 (OpenRouter)",
        provider: "openrouter",
        api: "openai-responses",
        context_window: 200_000,
        max_tokens: 8192
      },
      %PiAi.Model{
        id: "google/gemini-2.5-flash",
        name: "Gemini 2.5 Flash (OpenRouter)",
        provider: "openrouter",
        api: "openai-responses",
        context_window: 1_000_000,
        max_tokens: 64_000
      },
      %PiAi.Model{
        id: "deepseek/deepseek-chat",
        name: "DeepSeek V3 (OpenRouter)",
        provider: "openrouter",
        api: "openai-responses",
        context_window: 64_000,
        max_tokens: 8192
      }
    ]
  end

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        case PiAi.Auth.load("openrouter") do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env("OPENROUTER_API_KEY") || ""
        end
      key -> key
    end
  end
end
