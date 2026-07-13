defmodule PiAgent.LoopIntegrationTest do
  use ExUnit.Case, async: true
  alias PiAi.Message

  setup do
    reg = :loop_int_reg
    start_supervised!({PiAgent.Tool.Registry, name: reg})
    defmodule TestIntTool do
      @behaviour PiAgent.Tool
      def call(%{input: x}, _), do: {:ok, "result: #{x}"}
      def schema, do: %{type: "object", properties: %{input: %{type: "string"}}, required: [:input]}
    end
    PiAgent.Tool.Registry.register(:test_tool, TestIntTool, reg)
    %{registry: reg}
  end

  test "executes registered tool", %{registry: reg} do
    tc = %{id: "c1", type: "function", function: %{name: "test_tool", arguments: ~s({"input": "hello"})}}
    assert {:ok, %Message{role: :tool, content: "result: hello"}} = PiAgent.Loop.execute_tool(tc, %{}, reg)
  end

  test "processes openai response with text", %{registry: reg} do
    response = %{"content" => "hello", "tool_calls" => []}
    assert {:done, msgs} = PiAgent.Loop.process_response(response, [], %{}, reg, :openai)
    assert length(msgs) == 1
  end

  test "processes anthropic response", %{registry: reg} do
    response = %{"content" => [%{"type" => "text", "text" => "hello"}]}
    assert {:done, msgs} = PiAgent.Loop.process_response(response, [], %{}, reg, :anthropic)
    assert hd(msgs).content == "hello"
  end
end
