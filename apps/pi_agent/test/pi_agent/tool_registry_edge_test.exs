defmodule PiAgent.ToolRegistryEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiAgent.Tool.Registry)
  end
end
