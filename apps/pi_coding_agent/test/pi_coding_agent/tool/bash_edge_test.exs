defmodule PiCodingAgent.Tool.BashEdgeTest do
  use ExUnit.Case, async: false
  test "nonexistent command" do
    assert {:error, _} = PiCodingAgent.Tool.Bash.call(%{command: "nonexistent_command_xyz", timeout: 1}, %{})
  end
end
