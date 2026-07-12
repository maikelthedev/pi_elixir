defmodule PiCodingAgent.SessionTest do
  use ExUnit.Case, async: true

  alias PiAi.Message

  setup do
    # Backup and clean sessions for testing
    session_dir = Path.expand("~/.pi/agent/sessions")
    File.mkdir_p!(session_dir)
    :ok
  end

  describe "save and load" do
    test "saves and loads a session" do
      messages = [%Message{role: :user, content: "hello"}, %Message{role: :assistant, content: "hi"}]
      session_id = PiCodingAgent.Session.save(messages)

      assert {:ok, loaded_messages, _metadata} = PiCodingAgent.Session.load(session_id)
      assert length(loaded_messages) == 2

      # Clean up
      PiCodingAgent.Session.delete(session_id)
    end

    test "load returns error for unknown session" do
      assert {:error, _} = PiCodingAgent.Session.load("nonexistent_session")
    end
  end
end
