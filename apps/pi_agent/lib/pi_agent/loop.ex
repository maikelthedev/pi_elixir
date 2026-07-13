defmodule PiAgent.Loop do
  @moduledoc """
  Core agent loop that processes messages through an LLM provider,
  handles tool call execution, and recurses until completion.
  """

  alias PiAi.Message

  @doc """
  Executes a single tool call and returns a tool result message.

  The `tool_call` map follows the OpenAI-style format:
    %{id: "...", type: "function", function: %{name: "...", arguments: "..."}}
  """
  @spec execute_tool(map(), map(), atom()) :: {:ok, Message.t()} | {:error, term()}
  def execute_tool(tool_call, context, registry) do
    func = tool_call["function"] || tool_call[:function]
    name = func["name"] || func[:name]
    args_str = func["arguments"] || func[:arguments] || "{}"

    args =
      case args_str do
        s when is_binary(s) -> JSON.decode!(s) |> atomize_keys()
        m when is_map(m) -> m |> atomize_keys()
      end

    tool_name = String.to_atom(name)

    result = try do
      PiAgent.Tool.Registry.lookup(tool_name, registry)
    rescue
      _ -> :error
    catch
      :exit, _ -> :error
    end

    case result do
      {:ok, module} ->
        case module.call(args, context) do
          {:ok, result} ->
            result_content =
              cond do
                is_binary(result) -> result
                is_map(result) -> JSON.encode!(result)
                true -> inspect(result)
              end

            {:ok,
             %Message{
               role: :tool,
               content: result_content,
               tool_call_id: tool_call["id"] || tool_call[:id],
               name: name
             }}

          {:error, reason} ->
            {:ok,
             %Message{
               role: :tool,
               content: "Error: #{inspect(reason)}",
               tool_call_id: tool_call["id"] || tool_call[:id],
               name: name,
               is_error: true
             }}
        end

      :error ->
        {:error, "Unknown tool: #{name}"}
    end
  end

  @doc """
  Executes multiple tool calls sequentially.

  Returns a list of `{:ok, Message.t()}` or `{:error, term()}` tuples.
  """
  @spec execute_tools([map()], map(), atom()) :: [{:ok, Message.t()} | {:error, term()}]
  def execute_tools(tool_calls, context, registry) do
    Enum.map(tool_calls, &execute_tool(&1, context, registry))
  end

  @doc """
  Processes an LLM response and returns the appropriate action.

  Returns `{:done, messages}` when no tool calls remain, or
  `{:continue, messages, tool_calls}` when tools need execution.

  Supports both OpenAI-style (`content` array with tool_calls field)
  and Anthropic-style (`content` array with type: "tool_use") responses.
  """
  @spec process_response(map(), [Message.t()], map(), atom(), atom()) ::
          {:done, [Message.t()]} | {:continue, [Message.t()], [map()]}
  def process_response(response, pending_messages, context, registry, api_type \\ :openai)

  # Anthropic-style response: content array with tool_use blocks
  def process_response(response, pending_messages, _context, _registry, :anthropic) do
    content_blocks = response["content"] || []

    {text_parts, tool_calls} =
      Enum.split_with(content_blocks, fn block ->
        block["type"] != "tool_use"
      end)

    text = Enum.map_join(text_parts, "", & &1["text"])

    anthropic_tool_calls =
      Enum.map(tool_calls, fn tc ->
        %{
          id: tc["id"],
          type: "function",
          function: %{
            name: tc["name"],
            arguments: JSON.encode!(tc["input"])
          }
        }
      end)

    assistant_msg = %Message{role: :assistant, content: text, tool_calls: anthropic_tool_calls}
    all_messages = pending_messages ++ [assistant_msg]

    if anthropic_tool_calls == [] do
      {:done, all_messages}
    else
      {:continue, all_messages, anthropic_tool_calls}
    end
  end

  # OpenAI-style response: content string + tool_calls array
  def process_response(response, pending_messages, _context, _registry, :openai) do
    text = response["content"] || ""
    tool_calls = response["tool_calls"] || []

    assistant_msg = %Message{role: :assistant, content: text, tool_calls: tool_calls}
    all_messages = pending_messages ++ [assistant_msg]

    if tool_calls == [] do
      {:done, all_messages}
    else
      {:continue, all_messages, tool_calls}
    end
  end

  # Gemini-style: candidates array with functionCall parts
  def process_response(response, pending_messages, _context, _registry, :gemini) do
    candidates = response["candidates"] || []
    first = List.first(candidates, %{})
    content = first["content"] || %{}
    parts = content["parts"] || []

    {text_parts, fn_calls} =
      Enum.split_with(parts, fn p ->
        not Map.has_key?(p, "functionCall")
      end)

    text = Enum.map_join(text_parts, "", & &1["text"])

    tool_calls =
      Enum.map(fn_calls, fn fc ->
        func_call = fc["functionCall"]
        %{
          id: "fc_#{:erlang.unique_integer([:positive])}",
          type: "function",
          function: %{
            name: func_call["name"],
            arguments: JSON.encode!(func_call["args"] || %{})
          }
        }
      end)

    assistant_msg = %Message{role: :assistant, content: text, tool_calls: tool_calls}
    all_messages = pending_messages ++ [assistant_msg]

    if tool_calls == [] do
      {:done, all_messages}
    else
      {:continue, all_messages, tool_calls}
    end
  end

  # Private helpers

  defp atomize_keys(map) when is_map(map) do
    Map.new(map, fn
      {key, val} when is_binary(key) -> {String.to_atom(key), atomize_keys(val)}
      {key, val} -> {key, atomize_keys(val)}
    end)
  end

  defp atomize_keys(value), do: value
end
