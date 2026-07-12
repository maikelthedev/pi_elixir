defmodule PiAi.Provider.OpenAI do
  @moduledoc """
  Provider implementation for OpenAI's Responses API (Chat Completions).

  Converts PiAi.Message structs to OpenAI's API format and
  handles streaming via Req.
  """

  @behaviour PiAi.Provider

  @api_url "https://api.openai.com/v1/chat/completions"

  @doc """
  Converts a `PiAi.Message` to an OpenAI API message map.
  """
  @spec message_to_openai(PiAi.Message.t()) :: map()
  def message_to_openai(%PiAi.Message{role: :user, content: content}) do
    %{role: "user", content: content || ""}
  end

  def message_to_openai(%PiAi.Message{role: :system, content: content}) do
    %{role: "system", content: content || ""}
  end

  def message_to_openai(%PiAi.Message{role: :assistant, content: content, tool_calls: nil}) do
    %{role: "assistant", content: content || nil}
  end

  def message_to_openai(%PiAi.Message{role: :assistant, content: content, tool_calls: tool_calls}) do
    openai_calls =
      Enum.map(tool_calls || [], fn tc ->
        func = tc["function"] || tc[:function]

        %{
          id: tc["id"] || tc[:id],
          type: "function",
          function: %{
            name: func["name"] || func[:name],
            arguments: func["arguments"] || func[:arguments] || "{}"
          }
        }
      end)

    %{role: "assistant", content: content, tool_calls: openai_calls}
  end

  def message_to_openai(%PiAi.Message{role: :tool, content: content, tool_call_id: tc_id, name: _name}) do
    %{role: "tool", content: content || "", tool_call_id: tc_id}
  end

  @doc """
  Builds the full OpenAI API request body from messages and options.
  """
  @spec build_request_body(PiAi.Model.t(), [PiAi.Message.t()], keyword()) :: map()
  def build_request_body(model, messages, opts) do
    %{
      model: model.id,
      max_tokens: Keyword.get(opts, :max_tokens, 4096),
      messages: Enum.map(messages, &message_to_openai/1)
    }
    |> maybe_put(:temperature, Keyword.get(opts, :temperature))
    |> maybe_put(:top_p, Keyword.get(opts, :top_p))
    |> maybe_put(:stop, Keyword.get(opts, :stop))
  end

  @doc """
  Returns known OpenAI models.
  """
  @impl true
  @spec models() :: [PiAi.Model.t()]
  def models do
    [
      %PiAi.Model{
        id: "gpt-4o",
        name: "GPT-4o",
        provider: "openai",
        api: "openai-responses",
        context_window: 128_000,
        max_tokens: 16_384,
        input_cost: 2.5,
        output_cost: 10.0
      },
      %PiAi.Model{
        id: "gpt-4o-mini",
        name: "GPT-4o Mini",
        provider: "openai",
        api: "openai-responses",
        context_window: 128_000,
        max_tokens: 16_384,
        input_cost: 0.15,
        output_cost: 0.6
      },
      %PiAi.Model{
        id: "o1-preview",
        name: "O1 Preview",
        provider: "openai",
        api: "openai-responses",
        context_window: 128_000,
        max_tokens: 32_768,
        reasoning: true
      }
    ]
  end

  @impl PiAi.Provider
  def stream_chat(model, messages, opts) do
    body = build_request_body(model, messages, opts)
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
        into: fn chunk, _acc ->
          {:cont, chunk}
        end
      )

    case Req.post(request) do
      {:ok, %Req.Response{status: 200, body: body}} ->
        {:ok, [body]}

      {:ok, %Req.Response{status: status, body: body}} ->
        {:error, "OpenAI API error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private helpers

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        case PiAi.Auth.load("openai") do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env("OPENAI_API_KEY") || ""
        end

      key ->
        key
    end
  end
end
