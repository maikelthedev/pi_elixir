defmodule PiAi.Provider.AnthropicTest do
  use ExUnit.Case, async: true

  alias PiAi.Message
  alias PiAi.Model

  describe "message_to_anthropic/1" do
    test "converts a user message" do
      msg = %Message{role: :user, content: "hello"}
      result = PiAi.Provider.Anthropic.message_to_anthropic(msg)
      assert result.role == "user"
      assert result.content == [%{type: "text", text: "hello"}]
    end

    test "converts an assistant message" do
      msg = %Message{role: :assistant, content: "hi"}
      result = PiAi.Provider.Anthropic.message_to_anthropic(msg)
      assert result.role == "assistant"
    end

    test "converts an assistant message with tool calls" do
      msg = %Message{
        role: :assistant,
        content: "",
        tool_calls: [
          %{id: "call_1", type: "function", function: %{name: "read", arguments: ~s({"path": "foo"})}}
        ]
      }

      result = PiAi.Provider.Anthropic.message_to_anthropic(msg)
      assert result.role == "assistant"
      assert length(result.content) == 1
      assert %{type: "tool_use"} = hd(result.content)
    end

    test "converts a tool result message" do
      msg = %Message{role: :tool, content: "file ok", tool_call_id: "call_1", name: "read"}
      result = PiAi.Provider.Anthropic.message_to_anthropic(msg)
      assert result.role == "user"
      assert [%{type: "tool_result", tool_use_id: "call_1", content: "file ok"}] = result.content
    end
  end

  describe "build_request_body/3" do
    test "builds a valid request body" do
      model = %Model{id: "claude-sonnet-4-20250514"}
      messages = [%Message{role: :user, content: "hello"}]

      body = PiAi.Provider.Anthropic.build_request_body(model, messages, system: "Be helpful")
      assert body.model == "claude-sonnet-4-20250514"
      assert body.max_tokens == 4096
      assert body.system == "Be helpful"
      assert length(body.messages) == 1
    end

    test "includes max_tokens from opts" do
      model = %Model{id: "test"}
      body = PiAi.Provider.Anthropic.build_request_body(model, [], max_tokens: 8192)
      assert body.max_tokens == 8192
    end

    test "extracts system message from messages" do
      model = %Model{id: "test"}
      messages = [
        %Message{role: :system, content: "You are a helpful assistant"},
        %Message{role: :user, content: "hello"}
      ]

      body = PiAi.Provider.Anthropic.build_request_body(model, messages, [])
      assert body.system == "You are a helpful assistant"
      assert length(body.messages) == 1
    end
  end

  describe "models/0" do
    test "returns known Anthropic model list" do
      models = PiAi.Provider.Anthropic.models()
      assert is_list(models)
      assert length(models) > 0
      assert Enum.all?(models, &match?(%PiAi.Model{}, &1))
      assert Enum.any?(models, &(&1.id =~ "claude"))
    end
  end
end
