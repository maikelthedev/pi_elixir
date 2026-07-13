defmodule PiCodingAgent.CompactionTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "detects need for compaction" do
    msgs = for i <- 1..60, do: %Message{role: :user, content: "msg #{i}"}
    assert PiCodingAgent.Compaction.needed?(msgs)
  end
  test "builds summary from messages" do
    msgs = [%Message{role: :user, content: "hello"}, %Message{role: :assistant, content: "world"}]
    summary = PiCodingAgent.Compaction.build_summary(msgs)
    assert summary =~ "world"
  end
  test "compact splits messages" do
    msgs = for i <- 1..20, do: %Message{role: :user, content: "msg #{i}"}
    {:ok, {_summary, recent}} = PiCodingAgent.Compaction.compact(msgs, keep_recent: 5)
    assert length(recent) == 5
  end
end
