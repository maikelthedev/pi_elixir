defmodule PiAi.Provider.Groq do
  @moduledoc """
  Provider implementation for Groq's API (OpenAI-compatible).
  """
  @behaviour PiAi.Provider

  @api_url "https://api.groq.com/openai/v1/chat/completions"

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
          {"content-type", "application/json"}
        ],
        json: body,
        into: fn chunk, acc -> {:cont, chunk <> (acc || "")} end
      )

    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        response = PiAi.EventStream.accumulate([body])
        {:ok, [response]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Groq error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def models do
    [
      %PiAi.Model{
        id: "llama-3.3-70b-versatile",
        name: "Llama 3.3 70B",
        provider: "groq",
        api: "openai-responses",
        context_window: 128_000,
        max_tokens: 32_768,
        input_cost: 0.59,
        output_cost: 0.79
      },
      %PiAi.Model{
        id: "mixtral-8x7b-32768",
        name: "Mixtral 8x7B",
        provider: "groq",
        api: "openai-responses",
        context_window: 32_768,
        max_tokens: 4096
      },
      %PiAi.Model{
        id: "gemma2-9b-it",
        name: "Gemma 2 9B",
        provider: "groq",
        api: "openai-responses",
        context_window: 8192,
        max_tokens: 4096
      }
    ]
  end

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        case PiAi.Auth.load("groq") do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env("GROQ_API_KEY") || ""
        end
      key -> key
    end
  end
end
