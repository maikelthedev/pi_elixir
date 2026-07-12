defmodule PiAgent.AgentTest do
  use ExUnit.Case, async: true

  alias PiAi.Message

  setup do
    # Start tool registry
    registry = :agent_test_registry
    start_supervised!({PiAgent.Tool.Registry, name: registry})

    # Register a test tool
    defmodule TestEchoTool do
      @behaviour PiAgent.Tool
      def call(%{text: text}, _context), do: {:ok, "echo: #{text}"}
      def schema, do: %{type: "object", properties: %{text: %{type: "string"}}, required: [:text]}
    end

    PiAgent.Tool.Registry.register(:echo, TestEchoTool, registry)
    %{registry: registry}
  end

  describe "Agent start/stop" do
    test "starts and stops cleanly" do
      {:ok, pid} = PiAgent.Agent.start_link(model: %PiAi.Model{id: "test", name: "Test", provider: "test", api: "test"})
      assert is_pid(pid)
      Process.unlink(pid)
      Process.exit(pid, :kill)
    end
  end

  describe "message handling" do
    test "add_message adds a user message" do
      {:ok, pid} =
        PiAgent.Agent.start_link(
          model: %PiAi.Model{id: "test", name: "Test", provider: "test", api: "test"},
          registry: :agent_test_registry
        )

      msg = %Message{role: :user, content: "hello"}
      assert :ok = PiAgent.Agent.add_message(pid, msg)

      state = :sys.get_state(pid)
      assert length(state.messages) == 1
    end

    test "get_messages returns all messages" do
      {:ok, pid} =
        PiAgent.Agent.start_link(
          model: %PiAi.Model{id: "test", name: "Test", provider: "test", api: "test"},
          registry: :agent_test_registry
        )

      PiAgent.Agent.add_message(pid, %Message{role: :user, content: "q1"})
      PiAgent.Agent.add_message(pid, %Message{role: :user, content: "q2"})

      msgs = PiAgent.Agent.get_messages(pid)
      assert length(msgs) == 2
    end
  end

  describe "tool schema construction" do
    test "builds tool schemas from registry" do
      schemas = PiAgent.Agent.build_tool_schemas(:agent_test_registry)
      assert length(schemas) == 1

      schema = hd(schemas)
      assert schema.name == :echo
      assert schema.description == ""
    end
  end
end
