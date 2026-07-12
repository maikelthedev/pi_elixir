defmodule PiAi.Provider.AntLing do
  @moduledoc "Ant Ling (Anthropic China variant). Uses Anthropic Messages API format."
  @behaviour PiAi.Provider

  @impl true
  def stream_chat(model, messages, opts) do
    base_url = System.get_env("ANT_LING_URL") || "https://api.antling.com/v1/messages"
    api_key = resolve_api_key(opts)

    body = PiAi.Provider.Anthropic.build_request_body(model, messages, opts)

    request =
      Req.new(
        url: base_url,
        method: :post,
        headers: [
          {"x-api-key", api_key},
          {"anthropic-version", "2023-06-01"},
          {"content-type", "application/json"}
        ],
        json: body,
        into: fn chunk, acc -> {:cont, chunk <> (acc || "")} end
      )

    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        parsed = PiAi.EventStream.accumulate([body])
        text = parsed["content"] || ""
        {:ok, [%{"content" => text}]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Ant Ling error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def models do
    [%PiAi.Model{id: "ant-ling-v1", name: "Ant Ling v1", provider: "ant-ling", api: "anthropic-messages", context_window: 200_000, max_tokens: 8192}]
  end

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil -> System.get_env("ANT_LING_API_KEY") || ""
      key -> key
    end
  end
end
