defmodule PiCodingAgent.Tool.EditTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_edit_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  test "replaces exact text in a file", %{dir: dir} do
    path = Path.join(dir, "test.txt")
    File.write!(path, "hello world\nreplace me\nbye")

    assert {:ok, result} =
             PiCodingAgent.Tool.Edit.call(
               %{path: path, old_text: "replace me", new_text: "replaced!"},
               %{}
             )

    assert result =~ "replaced"
    assert File.read!(path) =~ "replaced!"
    refute File.read!(path) =~ "replace me"
  end

  test "returns error when old_text not found", %{dir: dir} do
    path = Path.join(dir, "test.txt")
    File.write!(path, "hello")

    assert {:error, _} =
             PiCodingAgent.Tool.Edit.call(
               %{path: path, old_text: "nonexistent", new_text: "whatever"},
               %{}
             )
  end

  test "returns error for missing file" do
    assert {:error, _} =
             PiCodingAgent.Tool.Edit.call(
               %{path: "/nonexistent.txt", old_text: "a", new_text: "b"},
               %{}
             )
  end
end
