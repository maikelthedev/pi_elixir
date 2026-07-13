defmodule PiCodingAgent.SDKTest do
  use ExUnit.Case, async: true
  test "version returns string" do
    assert is_binary(PiCodingAgent.SDK.version())
  end
  test "list_models returns list" do
    result = PiCodingAgent.SDK.list_models()
    assert is_list(result)
  end
end

defmodule PiCodingAgent.AgentSessionTest do
  use ExUnit.Case, async: false
  setup do
    start_supervised!({PiCodingAgent.AgentSession, name: :test_session, id: "test_session", model: "faux/test"})
    :ok
  end
  test "get_messages returns initial state" do
    msgs = PiCodingAgent.AgentSession.get_messages(:test_session)
    assert length(msgs) == 1
    assert hd(msgs).role == :system
  end
  test "clear_history resets messages" do
    :ok = PiCodingAgent.AgentSession.clear_history(:test_session)
    msgs = PiCodingAgent.AgentSession.get_messages(:test_session)
    assert length(msgs) == 1
  end
end
