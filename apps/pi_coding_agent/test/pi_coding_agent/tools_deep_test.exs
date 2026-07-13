defmodule PiCodingAgent.ToolsDeepTest do
  use ExUnit.Case, async: true
  alias PiCodingAgent.Tool

  test "bash tool has correct schema" do
    schema = Tool.Bash.schema()
    assert is_map(schema)
  end

  test "read tool has correct schema" do
    schema = Tool.Read.schema()
    assert is_map(schema)
  end

  test "write tool has correct schema" do
    schema = Tool.Write.schema()
    assert is_map(schema)
  end

  test "edit tool has correct schema" do
    schema = Tool.Edit.schema()
    assert is_map(schema)
  end

  test "ls tool has correct schema" do
    schema = Tool.Ls.schema()
    assert is_map(schema)
  end

  test "find tool has correct schema" do
    schema = Tool.Find.schema()
    assert is_map(schema)
  end

  test "grep tool has correct schema" do
    schema = Tool.Grep.schema()
    assert is_map(schema)
  end

  test "all tools return valid schemas" do
    tools = [Tool.Bash, Tool.Read, Tool.Write, Tool.Edit, Tool.Ls, Tool.Find, Tool.Grep, Tool.EditDiff, Tool.Truncate]
    Enum.each(tools, fn tool ->
      schema = tool.schema()
      assert is_map(schema), "#{inspect(tool)} schema should be a map"
    end)
  end
end
