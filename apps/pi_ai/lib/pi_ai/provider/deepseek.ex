defmodule PiAi.Provider.DeepSeek do
  @moduledoc """
  Provider implementation for DeepSeek's API (OpenAI-compatible).
  """
  @behaviour PiAi.Provider

  @api_url "https://api.deepseek.com/chat/completions"

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
        {:error, "DeepSeek error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def models do
    [
      %PiAi.Model{
        id: "deepseek-chat",
        name: "DeepSeek V3",
        provider: "deepseek",
        api: "openai-responses",
        context_window: 64_000,
        max_tokens: 8192,
        input_cost: 0.27,
        output_cost: 1.10
      },
      %PiAi.Model{
        id: "deepseek-reasoner",
        name: "DeepSeek R1",
        provider: "deepseek",
        api: "openai-responses",
        context_window: 64_000,
        max_tokens: 8192,
        reasoning: true,
        input_cost: 0.55,
        output_cost: 2.19
      }
    ]
  end

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        case PiAi.Auth.load("deepseek") do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env("DEEPSEEK_API_KEY") || ""
        end
      key -> key
    end
  end
end
