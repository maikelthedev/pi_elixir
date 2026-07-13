defmodule PiAgent.LoopEdgeTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "execute_tool unknown tool" do
    tc = %{id: "c1", type: "function", function: %{name: "nope", arguments: "{}"}}
    assert {:error, _} = PiAgent.Loop.execute_tool(tc, %{}, :nonexistent_registry)
  end
end
