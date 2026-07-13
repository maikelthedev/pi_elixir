defmodule PiCodingAgent.Messages do
  @moduledoc "Message formatting, token estimation, and conversation utilities."
  alias PiAi.Message

  def format_for_provider(messages) do
    messages
    |> Enum.map(&format_single/1)
    |> Enum.reject(&is_nil/1)
  end

  def format_single(%Message{} = msg) do
    base = %{"role" => to_string(msg.role), "content" => msg.content}
    base
    |> maybe_put("tool_call_id", msg.tool_call_id)
    |> maybe_put("name", msg.name)
    |> maybe_put("tool_calls", format_tool_calls(msg.tool_calls))
  end

  def format_single(%{"role" => _} = map), do: map
  def format_single(_), do: nil

  def count_tokens(messages) when is_list(messages) do
    Enum.reduce(messages, 0, fn msg, acc -> acc + count_tokens_single(msg) end)
  end

  def count_tokens_single(%Message{content: c}) when is_binary(c), do: div(String.length(c), 4) + 10
  def count_tokens_single(%{content: c}) when is_binary(c), do: div(String.length(c), 4) + 10
  def count_tokens_single(_), do: 50

  def compact(messages, max_tokens) do
    system = Enum.filter(messages, &(&1.role == :system))
    rest = Enum.reject(messages, &(&1.role == :system))
    {kept, _} = Enum.reduce_while(Enum.reverse(rest), {[], 0}, fn msg, {acc, tokens} ->
      t = count_tokens_single(msg)
      if tokens + t > max_tokens, do: {:halt, {acc, tokens}}, else: {:cont, {[msg | acc], tokens + t}}
    end)
    system ++ kept
  end

  def last_assistant(messages) do
    messages |> Enum.reverse() |> Enum.find(&(&1.role == :assistant))
  end

  def find_last_tool_call(messages) do
    messages
    |> Enum.reverse()
    |> Enum.find(fn
      %Message{tool_calls: tc} when is_list(tc) and tc != [] -> true
      _ -> false
    end)
  end

  defp format_tool_calls(nil), do: nil
  defp format_tool_calls([]), do: nil
  defp format_tool_calls(calls) when is_list(calls) do
    Enum.map(calls, fn
      %{id: id, name: name, arguments: args} ->
        %{id: id, name: name, arguments: args}
      %{id: id, function: %{name: name, arguments: args}} ->
        %{id: id, name: name, arguments: args}
      other -> other
    end)
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, false), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
