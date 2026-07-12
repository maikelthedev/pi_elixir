defmodule PiCodingAgent.Tool.BashTest do
  use ExUnit.Case, async: false

  test "executes a shell command and returns output" do
    assert {:ok, result} = PiCodingAgent.Tool.Bash.call(%{command: "echo hello world"}, %{})
    assert result =~ "hello world"
  end

  test "returns stderr on failure" do
    assert {:ok, result} = PiCodingAgent.Tool.Bash.call(%{command: "ls /nonexistent_path_xyz"}, %{})
    # Error output is captured
    assert result != ""
  end

  test "respects timeout option" do
    assert {:error, _} =
             PiCodingAgent.Tool.Bash.call(%{command: "sleep 10 && echo done", timeout: 1}, %{})
  end
end
