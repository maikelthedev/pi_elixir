defmodule PiCodingAgent.Compaction do
  @moduledoc """
  Context compaction for long conversations.

  Summarizes old messages into a compact entry to free
  context window space while preserving key information
  like file operations and decisions.
  """

  alias PiAi.Message

  @default_token_budget 5000

  @doc """
  Determines if compaction is needed based on message count.
  """
  @spec needed?([Message.t()], pos_integer()) :: boolean()
  def needed?(messages, threshold \\ 50) do
    length(messages) > threshold
  end

  @doc """
  Compacts a list of messages into a summary + recent messages.

  Returns `{:ok, {summary_message, recent_messages}}`.
  """
  @spec compact([Message.t()], keyword()) :: {:ok, {Message.t(), [Message.t()]}}
  def compact(messages, opts \\ []) do
    budget = Keyword.get(opts, :token_budget, @default_token_budget)
    keep_recent = Keyword.get(opts, :keep_recent, 10)

    # Split: keep recent N messages, compact the rest
    {old, recent} = Enum.split(messages, max(0, length(messages) - keep_recent))

    summary = build_summary(old)

    # Build a compaction summary message
    summary_msg = %Message{
      role: :system,
      content: "[Compaction summary of earlier conversation:\n#{summary}\n]"
    }

    {:ok, {summary_msg, recent}}
  end

  @doc """
  Builds a text summary from a list of messages.
  """
  @spec build_summary([Message.t()]) :: String.t()
  def build_summary(messages) do
    # Extract key information without calling an LLM
    {user_msgs, assistant_msgs, tool_msgs} = categorize(messages)

    parts = []

    parts = if user_msgs != [] do
      topics = extract_topics(user_msgs)
      ["User asked about: #{Enum.join(topics, ", ")}"]
    else parts end

    parts = if assistant_msgs != [] do
      key_points = extract_key_points(assistant_msgs)
      ["Key results: #{Enum.join(key_points, "; ")}"]
    else parts end

    parts = if tool_msgs != [] do
      files = extract_files(tool_msgs)
      ["Files touched: #{Enum.join(files, ", ")}"]
    else parts end

    total = length(messages)
    parts = ["Conversation: #{total} messages"] ++ parts

    Enum.join(parts, " | ")
  end

  defp categorize(messages) do
    Enum.reduce(messages, {[], [], []}, fn msg, {u, a, t} ->
      case msg.role do
        :user -> {[msg | u], a, t}
        :assistant -> {u, [msg | a], t}
        :tool -> {u, a, [msg | t]}
        _ -> {u, a, t}
      end
    end)
    |> then(fn {u, a, t} -> {Enum.reverse(u), Enum.reverse(a), Enum.reverse(t)} end)
  end

  defp extract_topics(user_msgs) do
    user_msgs
    |> Enum.map(& &1.content)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&(String.slice(&1, 0, 60)))
    |> Enum.take(5)
  end

  defp extract_key_points(assistant_msgs) do
    assistant_msgs
    |> Enum.map(& &1.content)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(&(String.slice(&1, 0, 80)))
    |> Enum.take(5)
  end

  defp extract_files(tool_msgs) do
    tool_msgs
    |> Enum.map(& &1.name)
    |> Enum.reject(&is_nil/1)
    |> Enum.uniq()
    |> Enum.take(10)
  end
end
