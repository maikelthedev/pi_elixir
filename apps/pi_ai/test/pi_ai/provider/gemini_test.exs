defmodule PiAi.Provider.GeminiTest do
  use ExUnit.Case, async: true

  alias PiAi.Message
  alias PiAi.Model

  describe "content_to_gemini/1" do
    test "converts a user message" do
      msg = %Message{role: :user, content: "hello"}
      result = PiAi.Provider.Gemini.content_to_gemini(msg)
      assert result.role == "user"
      assert [%{parts: [%{text: "hello"}]}] = result.contents
    end

    test "converts an assistant message" do
      msg = %Message{role: :assistant, content: "hi"}
      result = PiAi.Provider.Gemini.content_to_gemini(msg)
      assert result.role == "model"
    end

    test "extracts system instruction from system messages" do
      messages = [%Message{role: :system, content: "You are helpful"}, %Message{role: :user, content: "hello"}]
      {sys, body_messages} = PiAi.Provider.Gemini.extract_system_instruction(messages)

      assert sys == %{parts: [%{text: "You are helpful"}]}
      assert length(body_messages) == 1
    end

    test "converts a tool result message" do
      msg = %Message{role: :tool, content: "file ok", tool_call_id: "call_1", name: "read"}
      result = PiAi.Provider.Gemini.content_to_gemini(msg)
      assert result.role == "function"
    end
  end

  describe "build_request_body/3" do
    test "builds a valid request body" do
      model = %Model{id: "gemini-2.5-flash"}
      messages = [%Message{role: :user, content: "hello"}]

      body = PiAi.Provider.Gemini.build_request_body(model, messages, [])
      assert body.contents != nil
    end

    test "includes system instruction when present" do
      model = %Model{id: "gemini-2.5-flash"}
      messages = [%Message{role: :system, content: "Be concise"}, %Message{role: :user, content: "hello"}]

      body = PiAi.Provider.Gemini.build_request_body(model, messages, [])
      assert body.system_instruction != nil
      assert length(body.contents) == 1
    end
  end

  describe "models/0" do
    test "returns known Gemini model list" do
      models = PiAi.Provider.Gemini.models()
      assert is_list(models)
      assert length(models) > 0
      assert Enum.all?(models, &match?(%PiAi.Model{}, &1))
      assert Enum.any?(models, &(&1.id =~ "gemini"))
    end
  end
end
