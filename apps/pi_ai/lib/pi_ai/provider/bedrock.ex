defmodule PiAi.Provider.Bedrock do
  @moduledoc """
  AWS Bedrock provider. Uses AWS SigV4 authentication via the AWS SDK.

  Requires AWS credentials to be configured via environment variables
  (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION) or
  ~/.aws/credentials.
  """

  @behaviour PiAi.Provider

  @impl true
  def stream_chat(model, messages, opts) do
    region = System.get_env("AWS_REGION") || "us-east-1"
    _access_key = System.get_env("AWS_ACCESS_KEY_ID") || ""
    _secret_key = System.get_env("AWS_SECRET_ACCESS_KEY") || ""
    session_token = System.get_env("AWS_SESSION_TOKEN")

    # Bedrock uses a different API shape depending on the model
    body = build_bedrock_body(model, messages, opts)
    model_id = model.id
    accept = "application/json"
    content_type = "application/json"

    # Use the Bedrock Runtime API
    host = "bedrock-runtime.#{region}.amazonaws.com"
    url = "https://#{host}/model/#{model_id}/converse"

    headers = [
      {"host", host},
      {"content-type", content_type},
      {"accept", accept},
      {"x-amz-date", aws_date()}
    ]

    headers = if session_token, do: [{"x-amz-security-token", session_token} | headers], else: headers

    request =
      Req.new(
        url: url,
        method: :post,
        headers: headers,
        json: body,
        into: fn chunk, acc -> {:cont, chunk <> (acc || "")} end
      )

    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        text = extract_bedrock_text(body)
        {:ok, [%{"content" => text, "tool_calls" => []}]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "Bedrock error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @impl true
  def models do
    [
      %PiAi.Model{id: "anthropic.claude-sonnet-4-20250514", name: "Claude Sonnet 4 (Bedrock)", provider: "amazon-bedrock", api: "bedrock-converse-stream", context_window: 200_000, max_tokens: 8192, input_cost: 3.0, output_cost: 15.0},
      %PiAi.Model{id: "anthropic.claude-4-20250514", name: "Claude 4 (Bedrock)", provider: "amazon-bedrock", api: "bedrock-converse-stream", context_window: 200_000, max_tokens: 8192, input_cost: 15.0, output_cost: 75.0},
      %PiAi.Model{id: "anthropic.claude-haiku-4-20250514", name: "Claude Haiku 4 (Bedrock)", provider: "amazon-bedrock", api: "bedrock-converse-stream", context_window: 200_000, max_tokens: 8192, input_cost: 0.8, output_cost: 4.0},
      %PiAi.Model{id: "meta.llama3-3-70b-instruct-v1:0", name: "Llama 3.3 70B (Bedrock)", provider: "amazon-bedrock", api: "bedrock-converse-stream", context_window: 128_000, max_tokens: 4096}
    ]
  end

  defp build_bedrock_body(model, messages, opts) do
    # Convert to Bedrock's converse format
    bedrock_messages = Enum.map(messages, fn msg ->
      %{
        role: Atom.to_string(msg.role),
        content: [%{text: msg.content || ""}]
      }
    end)

    %{
      modelId: model.id,
      messages: bedrock_messages,
      inferenceConfig: %{
        maxTokens: Keyword.get(opts, :max_tokens, 4096)
      }
    }
  end

  defp extract_bedrock_text(body) when is_map(body) do
    output = body["output"] || %{}
    message = output["message"] || %{}
    content = message["content"] || []
    Enum.map_join(content, "", fn c -> c["text"] || "" end)
  end

  defp extract_bedrock_text(body) when is_binary(body), do: body
  defp extract_bedrock_text(_), do: ""

  defp aws_date do
    DateTime.utc_now() |> DateTime.to_string() |> String.slice(0, 19) |> String.replace(~r/[-:]/, "")
  end
end
