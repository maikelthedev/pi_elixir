defmodule PiAgent.Harness.Session do
  @moduledoc "Session management combining memory and JSONL storage."
  defstruct [:id, :messages, :metadata, :created_at, :updated_at]

  @type t :: %__MODULE__{
    id: String.t(), messages: [PiAi.Message.t()], metadata: map(),
    created_at: DateTime.t(), updated_at: DateTime.t()
  }

  def new(id, messages \\ [], metadata \\ %{}) do
    now = DateTime.utc_now()
    %__MODULE__{id: id, messages: messages, metadata: metadata, created_at: now, updated_at: now}
  end

  def add_message(%__MODULE__{} = session, %PiAi.Message{} = msg) do
    %{session | messages: session.messages ++ [msg], updated_at: DateTime.utc_now()}
  end

  def add_messages(%__MODULE__{} = session, messages) when is_list(messages) do
    %{session | messages: session.messages ++ messages, updated_at: DateTime.utc_now()}
  end

  def clear(%__MODULE__{} = session) do
    %{session | messages: [], updated_at: DateTime.utc_now()}
  end

  def message_count(%__MODULE__{messages: msgs}), do: length(msgs)
  def token_estimate(%__MODULE__{messages: msgs}) do
    Enum.reduce(msgs, 0, fn msg, acc -> acc + token_estimate_msg(msg) end)
  end

  defp token_estimate_msg(%{content: c}) when is_binary(c), do: div(String.length(c), 4)
  defp token_estimate_msg(_), do: 50

  def to_map(%__MODULE__{} = s) do
    %{id: s.id, messages: s.messages, metadata: s.metadata,
      created_at: s.created_at, updated_at: s.updated_at}
  end

  def from_map(%{} = m) do
    %__MODULE__{
      id: m["id"] || m[:id],
      messages: m["messages"] || m[:messages] || [],
      metadata: m["metadata"] || m[:metadata] || %{},
      created_at: m["created_at"] || m[:created_at] || DateTime.utc_now(),
      updated_at: m["updated_at"] || m[:updated_at] || DateTime.utc_now()
    }
  end
end
