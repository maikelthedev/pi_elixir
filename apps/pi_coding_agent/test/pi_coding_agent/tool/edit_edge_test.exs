defmodule PiCodingAgent.Tool.EditEdgeTest do
  use ExUnit.Case, async: true
  test "edit nonexistent file" do
    assert {:error, _} = PiCodingAgent.Tool.Edit.call(%{path: "/nonexistent_path_xyz", old_text: "a", new_text: "b"}, %{})
  end
end
