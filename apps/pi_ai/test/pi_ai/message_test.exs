defmodule PiAi.MessageTest do
  use ExUnit.Case, async: true

  describe "struct" do
    test "constructs a user message" do
      msg = %PiAi.Message{role: :user, content: "hello"}
      assert msg.role == :user
      assert msg.content == "hello"
      assert msg.tool_calls == nil
      assert msg.tool_call_id == nil
    end

    test "constructs an assistant message with tool calls" do
      msg = %PiAi.Message{
        role: :assistant,
        content: "",
        tool_calls: [%{id: "call_1", type: "function", function: %{name: "read", arguments: ~s({"path": "foo"})}}]
      }
      assert msg.role == :assistant
      assert length(msg.tool_calls) == 1
    end

    test "constructs a tool result message" do
      msg = %PiAi.Message{role: :tool, content: "file contents", tool_call_id: "call_1", name: "read"}
      assert msg.role == :tool
      assert msg.tool_call_id == "call_1"
      assert msg.name == "read"
    end
  end
end
