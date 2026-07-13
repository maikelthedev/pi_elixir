defmodule PiCodingAgent.LsToolTest do
  use ExUnit.Case, async: true
  test "lists root directory" do
    assert {:ok, result} = PiCodingAgent.Tool.Ls.call(%{path: "/tmp"}, %{})
    assert is_binary(result)
  end
end
