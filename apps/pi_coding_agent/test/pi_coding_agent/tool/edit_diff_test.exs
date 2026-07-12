defmodule PiCodingAgent.Tool.EditDiffTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_editdiff_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  test "replaces single occurrence", %{dir: dir} do
    path = Path.join(dir, "test.txt")
    File.write!(path, "hello world\nthis is old\ngoodbye")

    {:ok, result} = PiCodingAgent.Tool.EditDiff.call(%{
      path: path, old_text: "old", new_text: "new"
    }, %{})

    assert result =~ "1 change"
    assert File.read!(path) =~ "new"
    refute File.read!(path) =~ "old"
  end

  test "replaces all occurrences with count: -1", %{dir: dir} do
    path = Path.join(dir, "test.txt")
    File.write!(path, "a b a b a")

    {:ok, result} = PiCodingAgent.Tool.EditDiff.call(%{
      path: path, old_text: "a", new_text: "x", count: -1
    }, %{})

    assert result =~ "3"
    assert File.read!(path) == "x b x b x"
  end

  test "returns error when old_text not found", %{dir: dir} do
    path = Path.join(dir, "test.txt")
    File.write!(path, "hello")

    {:error, _} = PiCodingAgent.Tool.EditDiff.call(%{
      path: path, old_text: "nonexistent", new_text: "x"
    }, %{})
  end
end
