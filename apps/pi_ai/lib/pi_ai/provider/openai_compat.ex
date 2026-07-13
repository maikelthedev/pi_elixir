defmodule PiAi.Provider.OpenAICompat do
  @moduledoc """
  Shared streaming implementation for OpenAI-compatible providers.

  Providers that use the `/v1/chat/completions` endpoint with the
  same request format can delegate to this module.
  """

  @doc """
  Standard OpenAI-compatible streaming chat.

  Calls the given URL with OpenAI-format messages and accumulates
  the SSE stream into a complete response.
  """
  @spec stream_chat(String.t(), PiAi.Model.t(), [PiAi.Message.t()], keyword(), String.t()) ::
          {:ok, [map()]} | {:error, term()}
  def stream_chat(api_url, model, messages, opts, provider_key) do
    body = %{
      model: model.id,
      max_tokens: Keyword.get(opts, :max_tokens, 4096),
      messages: Enum.map(messages, &PiAi.Provider.OpenAI.message_to_openai/1),
      stream: Keyword.get(opts, :stream, true)
    }

    body =
      if temp = Keyword.get(opts, :temperature) do
        Map.put(body, :temperature, temp)
      else
        body
      end

    api_key = resolve_api_key(provider_key, opts)

    request =
      Req.new(
        url: api_url,
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
        {:error, "#{provider_key} API error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp resolve_api_key(provider_key, opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        env_var = String.upcase(provider_key) <> "_API_KEY"

        case PiAi.Auth.load(provider_key) do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env(env_var) || ""
        end

      key ->
        key
    end
  end
end
