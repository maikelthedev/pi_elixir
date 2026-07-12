defmodule PiAi.Provider.Anthropic do
  @moduledoc """
  Provider implementation for Anthropic's Messages API.

  Converts PiAi.Message structs to Anthropic's API format and
  handles streaming via Server-Sent Events through Req.
  """

  @behaviour PiAi.Provider

  @api_url "https://api.anthropic.com/v1/messages"
  @anthropic_version "2023-06-01"

  @doc """
  Converts a `PiAi.Message` to an Anthropic API content block.
  """
  @spec message_to_anthropic(PiAi.Message.t()) :: map()
  def message_to_anthropic(%PiAi.Message{role: :user, content: content}) do
    %{role: "user", content: text_or_list(content)}
  end

  def message_to_anthropic(%PiAi.Message{role: :system, content: content}) do
    %{role: "user", content: text_or_list(content)}
  end

  def message_to_anthropic(%PiAi.Message{role: :assistant, content: content, tool_calls: nil}) do
    %{role: "assistant", content: text_or_list(content)}
  end

  def message_to_anthropic(%PiAi.Message{role: :assistant, content: _content, tool_calls: tool_calls}) do
    content_blocks =
      Enum.map(tool_calls || [], fn tc ->
        func = tc["function"] || tc[:function]

        input =
          case func["arguments"] || func[:arguments] do
            args when is_binary(args) -> JSON.decode!(args)
            args when is_map(args) -> args
            nil -> %{}
          end

        %{
          type: "tool_use",
          id: tc["id"] || tc[:id],
          name: func["name"] || func[:name],
          input: input
        }
      end)

    %{role: "assistant", content: content_blocks}
  end

  def message_to_anthropic(%PiAi.Message{role: :tool, content: content, tool_call_id: tc_id, name: _name}) do
    %{
      role: "user",
      content: [%{type: "tool_result", tool_use_id: tc_id, content: content || ""}]
    }
  end

  @doc """
  Builds the full Anthropic API request body from messages and options.
  """
  @spec build_request_body(PiAi.Model.t(), [PiAi.Message.t()], keyword()) :: map()
  def build_request_body(model, messages, opts) do
    {system_text, llm_messages} = extract_system(messages)

    body = %{
      model: model.id,
      max_tokens: Keyword.get(opts, :max_tokens, 4096),
      messages: Enum.map(llm_messages, &message_to_anthropic/1)
    }

    body =
      cond do
        system_text -> Map.put(body, :system, system_text)
        Keyword.has_key?(opts, :system) -> Map.put(body, :system, opts[:system])
        true -> body
      end

    if thinking = Keyword.get(opts, :thinking) do
      Map.put(body, :thinking, %{type: "enabled", budget_tokens: thinking})
    else
      body
    end
  end

  @impl true
  @spec models() :: [PiAi.Model.t()]
  def models do
    [
      %PiAi.Model{
        id: "claude-sonnet-4-20250514",
        name: "Claude Sonnet 4",
        provider: "anthropic",
        api: "anthropic-messages",
        context_window: 200_000,
        max_tokens: 8192,
        input_cost: 3.0,
        output_cost: 15.0
      },
      %PiAi.Model{
        id: "claude-4-20250514",
        name: "Claude 4",
        provider: "anthropic",
        api: "anthropic-messages",
        context_window: 200_000,
        max_tokens: 8192,
        input_cost: 15.0,
        output_cost: 75.0
      },
      %PiAi.Model{
        id: "claude-haiku-4-20250514",
        name: "Claude Haiku 4",
        provider: "anthropic",
        api: "anthropic-messages",
        context_window: 200_000,
        max_tokens: 8192,
        input_cost: 0.8,
        output_cost: 4.0
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
          {"x-api-key", api_key},
          {"anthropic-version", @anthropic_version},
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
        {:error, "Anthropic API error (#{status}): #{inspect(body)}"}

      {:error, reason} ->
        {:error, reason}
    end
  end

  # Private helpers

  defp text_or_list(content) when is_binary(content), do: [%{type: "text", text: content}]
  defp text_or_list(content), do: content

  defp extract_system(messages) do
    {system_msgs, rest} = Enum.split_while(messages, &(&1.role == :system))

    system_text =
      case system_msgs do
        [] -> nil
        msgs -> msgs |> Enum.map(& &1.content) |> Enum.join("\n")
      end

    {system_text, rest}
  end

  defp resolve_api_key(opts) do
    case Keyword.get(opts, :api_key) do
      nil ->
        case PiAi.Auth.load("anthropic") do
          {:ok, %{"api_key" => key}} -> key
          _ -> System.get_env("ANTHROPIC_API_KEY") || ""
        end

      key ->
        key
    end
  end
end
