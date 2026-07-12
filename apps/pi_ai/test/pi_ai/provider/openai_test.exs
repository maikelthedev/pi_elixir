defmodule PiAi.Provider.OpenAITest do
  use ExUnit.Case, async: true

  alias PiAi.Message
  alias PiAi.Model

  describe "message_to_openai/1" do
    test "converts a user message" do
      msg = %Message{role: :user, content: "hello"}
      result = PiAi.Provider.OpenAI.message_to_openai(msg)
      assert result.role == "user"
      assert result.content == "hello"
    end

    test "converts an assistant message" do
      msg = %Message{role: :assistant, content: "hi"}
      result = PiAi.Provider.OpenAI.message_to_openai(msg)
      assert result.role == "assistant"
      assert result.content == "hi"
    end

    test "converts an assistant message with tool calls" do
      msg = %Message{
        role: :assistant,
        content: nil,
        tool_calls: [
          %{id: "call_1", type: "function", function: %{name: "read", arguments: ~s({"path": "foo"})}}
        ]
      }

      result = PiAi.Provider.OpenAI.message_to_openai(msg)
      assert result.role == "assistant"
      assert result.content == nil
      assert length(result.tool_calls) == 1
    end

    test "converts a tool result message" do
      msg = %Message{role: :tool, content: "file ok", tool_call_id: "call_1", name: "read"}
      result = PiAi.Provider.OpenAI.message_to_openai(msg)
      assert result.role == "tool"
      assert result.content == "file ok"
      assert result.tool_call_id == "call_1"
    end

    test "converts a system message" do
      msg = %Message{role: :system, content: "Be helpful"}
      result = PiAi.Provider.OpenAI.message_to_openai(msg)
      assert result.role == "system"
      assert result.content == "Be helpful"
    end
  end

  describe "build_request_body/3" do
    test "builds a valid request body" do
      model = %Model{id: "gpt-4o"}
      messages = [%Message{role: :user, content: "hello"}]

      body = PiAi.Provider.OpenAI.build_request_body(model, messages, [])
      assert body.model == "gpt-4o"
      assert body.max_tokens == 4096
      assert length(body.messages) == 1
    end

    test "includes max_tokens from opts" do
      model = %Model{id: "test"}
      body = PiAi.Provider.OpenAI.build_request_body(model, [], max_tokens: 8192)
      assert body.max_tokens == 8192
    end

    test "includes temperature from opts" do
      model = %Model{id: "test"}
      body = PiAi.Provider.OpenAI.build_request_body(model, [], temperature: 0.7)
      assert body.temperature == 0.7
    end
  end

  describe "models/0" do
    test "returns known OpenAI model list" do
      models = PiAi.Provider.OpenAI.models()
      assert is_list(models)
      assert length(models) > 0
      assert Enum.all?(models, &match?(%PiAi.Model{}, &1))
      assert Enum.any?(models, &(&1.id =~ "gpt"))
    end
  end
end
