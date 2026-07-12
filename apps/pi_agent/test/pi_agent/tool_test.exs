defmodule PiAgent.ToolTest do
  use ExUnit.Case, async: true

  describe "behaviour" do
    test "valid tool module implements the behaviour" do
      defmodule ValidTool do
        @behaviour PiAgent.Tool

        def call(%{path: path}, _context), do: {:ok, "read #{path}"}
        def schema, do: %{type: "object", properties: %{path: %{type: "string"}}, required: [:path]}
      end

      assert function_exported?(ValidTool, :call, 2)
      assert function_exported?(ValidTool, :schema, 0)
    end
  end

  describe "Tool.Registry" do
    setup do
      registry_name = :test_tool_registry
      start_supervised!({PiAgent.Tool.Registry, name: registry_name})
      %{registry: registry_name}
    end

    test "register and lookup a tool", %{registry: reg} do
      defmodule MyTool do
        @behaviour PiAgent.Tool
        def call(_args, _context), do: {:ok, "done"}
        def schema, do: %{type: "object"}
      end

      assert :ok = PiAgent.Tool.Registry.register(:mytool, MyTool, reg)
      assert {:ok, MyTool} = PiAgent.Tool.Registry.lookup(:mytool, reg)
    end

    test "lookup returns error for unknown tool", %{registry: reg} do
      assert :error = PiAgent.Tool.Registry.lookup(:nonexistent, reg)
    end

    test "list all registered tools", %{registry: reg} do
      defmodule ToolA do
        @behaviour PiAgent.Tool
        def call(_args, _context), do: {:ok, "a"}
        def schema, do: %{type: "object"}
      end

      defmodule ToolB do
        @behaviour PiAgent.Tool
        def call(_args, _context), do: {:ok, "b"}
        def schema, do: %{type: "object"}
      end

      PiAgent.Tool.Registry.register(:tool_a, ToolA, reg)
      PiAgent.Tool.Registry.register(:tool_b, ToolB, reg)

      tools = PiAgent.Tool.Registry.list(reg)
      assert :tool_a in tools
      assert :tool_b in tools
    end
  end
end
