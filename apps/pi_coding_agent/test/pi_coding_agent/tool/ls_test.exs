defmodule PiCodingAgent.Tool.LsTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_ls_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    File.write!(Path.join(tmp, "a.txt"), "a")
    File.write!(Path.join(tmp, "b.txt"), "b")
    File.mkdir_p!(Path.join(tmp, "subdir"))

    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  test "lists directory contents", %{dir: dir} do
    assert {:ok, result} = PiCodingAgent.Tool.Ls.call(%{path: dir}, %{})
    assert result =~ "a.txt"
    assert result =~ "b.txt"
    assert result =~ "subdir"
  end

  test "returns error for missing directory" do
    assert {:error, _} = PiCodingAgent.Tool.Ls.call(%{path: "/nonexistent"}, %{})
  end
end
