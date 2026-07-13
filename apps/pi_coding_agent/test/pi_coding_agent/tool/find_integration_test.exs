defmodule PiCodingAgent.FindToolTest do
  use ExUnit.Case, async: true
  test "finds files in /tmp" do
    assert {:ok, result} = PiCodingAgent.Tool.Find.call(%{path: "/tmp"}, %{})
    assert is_binary(result)
  end
end
