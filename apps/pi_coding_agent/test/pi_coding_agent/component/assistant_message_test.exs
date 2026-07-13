defmodule PiCodingAgent.Component.AssistantMessageTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "renders assistant message" do
    msg = %Message{role: :assistant, content: "hello", tool_calls: nil}
    lines = PiCodingAgent.Component.AssistantMessage.render(msg)
    assert length(lines) > 0
    assert Enum.join(lines) =~ "hello"
  end
  test "renders tool calls" do
    calls = [%{id: "c1", type: "function", function: %{name: "read", arguments: ~s({"path":"foo"})}}]
    msg = %Message{role: :assistant, content: "", tool_calls: calls}
    lines = PiCodingAgent.Component.AssistantMessage.render(msg)
    joined = Enum.join(lines)
    assert joined =~ "read"
  end
end
