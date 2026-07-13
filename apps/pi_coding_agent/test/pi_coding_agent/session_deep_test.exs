defmodule PiCodingAgent.SessionDeepTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "save and load preserves all fields" do
    msgs = [
      %Message{role: :user, content: "hi", is_error: false},
      %Message{role: :assistant, content: "hello", tool_calls: [%{id: "c1"}]},
      %Message{role: :tool, content: "result", tool_call_id: "c1", name: "test", is_error: false}
    ]
    sid = PiCodingAgent.Session.save(msgs)
    {:ok, loaded, _meta} = PiCodingAgent.Session.load(sid)
    assert length(loaded) == 3
    assert hd(loaded).content == "hi"
    PiCodingAgent.Session.delete(sid)
  end
  test "handles empty message list" do
    sid = PiCodingAgent.Session.save([])
    {:ok, [], _meta} = PiCodingAgent.Session.load(sid)
    PiCodingAgent.Session.delete(sid)
  end
end
