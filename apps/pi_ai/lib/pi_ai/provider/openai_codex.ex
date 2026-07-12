defmodule PiAi.Provider.OpenAICodex do
  @moduledoc "OpenAI Codex API (legacy, for fine-tuned code models)."
  @behaviour PiAi.Provider

  @api_url "https://api.openai.com/v1/completions"

  @impl true
  def stream_chat(model, messages, opts) do
    # Codex uses the older completions API, not chat completions
    prompt = Enum.map_join(messages, "\n", fn m -> "#{m.role}: #{m.content}" end)

    body = %{
      model: model.id,
      prompt: prompt <> "\nassistant:",
      max_tokens: Keyword.get(opts, :max_tokens, 4096)
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
        parsed = PiAi.EventStream.accumulate([body])
        text = parsed["content"] || parsed["text"] || ""
        {:ok, [%{"content" => text, "tool_calls" => []}]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "OpenAI Codex error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def models do
    [
      %PiAi.Model{id: "code-davinci-002", name: "Codex Davinci", provider: "openai-codex", api: "openai-completions", context_window: 8192, max_tokens: 4096}
    ]
  end

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        case PiAi.Auth.load("openai-codex") do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env("OPENAI_API_KEY") || ""
        end
      key -> key
    end
  end
end
