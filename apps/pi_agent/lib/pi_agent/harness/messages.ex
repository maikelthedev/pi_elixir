defmodule PiAgent.Harness.Messages do
  @moduledoc "Message formatting and management for the agent harness."
  alias PiAi.Message

  def format_messages(messages) when is_list(messages) do
    Enum.map(messages, &format_message/1)
  end

  def format_message(%Message{} = msg) do
    base = %{"role" => to_string(msg.role), "content" => msg.content}
    base
    |> maybe_put("tool_call_id", msg.tool_call_id)
    |> maybe_put("name", msg.name)
    |> maybe_put("is_error", msg.is_error)
  end

  def format_message(map) when is_map(map), do: map

  def compact_messages(messages, max_tokens \\ 100_000) do
    system = Enum.filter(messages, &(&1.role == :system))
    non_system = Enum.reject(messages, &(&1.role == :system))
    {kept, _} = Enum.reduce_while(Enum.reverse(non_system), {[], 0}, fn msg, {acc, tokens} ->
      est = estimate_tokens(msg)
      if tokens + est > max_tokens, do: {:halt, {acc, tokens}}, else: {:cont, {[msg | acc], tokens + est}}
    end)
    system ++ kept
  end

  def split_at_tool_response(messages) do
    Enum.split_while(messages, fn msg -> msg.role != :tool end)
  end

  def last_assistant_message(messages) do
    messages |> Enum.reverse() |> Enum.find(&(&1.role == :assistant))
  end

  def user_messages(messages), do: Enum.filter(messages, &(&1.role == :user))
  def assistant_messages(messages), do: Enum.filter(messages, &(&1.role == :assistant))

  defp estimate_tokens(%Message{content: c}) when is_binary(c), do: div(String.length(c), 4)
  defp estimate_tokens(_), do: 50

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, _key, false), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end
