defmodule PiAgent.Proxy do
  @moduledoc "Proxy stream function for routing LLM calls through an external server."
  defstruct [:server_url, :api_key, :timeout]

  def new(opts) do
    %__MODULE__{
      server_url: Keyword.get(opts, :server_url, System.get_env("PI_PROXY_URL")),
      api_key: Keyword.get(opts, :api_key, System.get_env("PI_PROXY_API_KEY")),
      timeout: Keyword.get(opts, :timeout, 30_000)
    }
  end

  def stream_chat(%__MODULE__{server_url: url, api_key: key, timeout: to}, model, messages, opts) do
    req_body = %{
      model: model.id,
      messages: Enum.map(messages, fn m -> %{role: m.role, content: m.content} end),
      max_tokens: Keyword.get(opts, :max_tokens, 4096),
      stream: true
    }
    headers = [{"content-type", "application/json"}]
    headers = if key, do: [{"authorization", "Bearer #{key}"} | headers], else: headers

    request = Req.new(url: url <> "/v1/chat/completions", method: :post, headers: headers, json: req_body)
    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} -> {:ok, [body]}
      {:ok, %Req.Response{status: s, body: b}} -> {:error, "Proxy error (#{s}): #{inspect(b)}"}
      {:error, reason} -> {:error, reason}
    end
  end
end
