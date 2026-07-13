defmodule PiCodingAgent.SessionManagerTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "creates and manages branches" do
    sm = PiCodingAgent.SessionManager.new()
    sm = PiCodingAgent.SessionManager.add_message(sm, %Message{role: :user, content: "hi"})
    {:ok, sm} = PiCodingAgent.SessionManager.fork(sm, :feature)
    assert PiCodingAgent.SessionManager.switch_branch(sm, :feature) == {:ok, sm}
    branches = PiCodingAgent.SessionManager.list_branches(sm)
    assert length(branches) == 2
  end
  test "round-trips session" do
    sm = PiCodingAgent.SessionManager.new(session_id: "test_session_123")
    sm = PiCodingAgent.SessionManager.add_message(sm, %Message{role: :user, content: "test"})
    PiCodingAgent.SessionManager.save(sm, "/tmp")
    {:ok, loaded} = PiCodingAgent.SessionManager.load("test_session_123", "/tmp")
    msgs = PiCodingAgent.SessionManager.messages(loaded)
    assert length(msgs) == 1
  after
    File.rm("/tmp/test_session_123.json")
  end
end
