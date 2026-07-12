defmodule PiAgent.LoopTest do
  use ExUnit.Case, async: true

  alias PiAi.Message

  setup do
    registry = :loop_test_registry
    start_supervised!({PiAgent.Tool.Registry, name: registry})

    defmodule LoopEcho do
      @behaviour PiAgent.Tool
      def call(%{text: text}, _context), do: {:ok, "echo: #{text}"}
      def schema, do: %{type: "object", properties: %{text: %{type: "string"}}, required: [:text]}
    end

    PiAgent.Tool.Registry.register(:echo, LoopEcho, registry)
    %{registry: registry}
  end

  describe "execute_tool/3" do
    test "executes a registered tool and returns result" do
      tool_call = %{
        id: "call_1",
        type: "function",
        function: %{name: "echo", arguments: ~s({"text": "hello"})}
      }

      assert {:ok, %Message{role: :tool, content: "echo: hello", tool_call_id: "call_1"}} =
               PiAgent.Loop.execute_tool(tool_call, %{}, :loop_test_registry)
    end

    test "returns error for unknown tool" do
      tool_call = %{
        id: "call_1",
        type: "function",
        function: %{name: "nonexistent", arguments: "{}"}
      }

      assert {:error, _} = PiAgent.Loop.execute_tool(tool_call, %{}, :loop_test_registry)
    end
  end

  describe "execute_tools/3" do
    test "executes multiple tools sequentially" do
      tool_calls = [
        %{id: "call_1", type: "function", function: %{name: "echo", arguments: ~s({"text": "a"})}},
        %{id: "call_2", type: "function", function: %{name: "echo", arguments: ~s({"text": "b"})}}
      ]

      results = PiAgent.Loop.execute_tools(tool_calls, %{}, :loop_test_registry)
      assert length(results) == 2
      assert Enum.all?(results, fn {:ok, _msg} -> true; _ -> false end)
    end
  end

  describe "process_response/4" do
    test "handles a text-only response (no tool calls)" do
      response = %{
        "content" => [%{"type" => "text", "text" => "Hello, world!"}]
      }

      result = PiAgent.Loop.process_response(response, [], %{}, :loop_test_registry, :openai)
      assert {:done, messages} = result
      assert length(messages) == 1
      assert hd(messages).role == :assistant
    end
  end
end
