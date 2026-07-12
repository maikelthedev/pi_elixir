defmodule PiCodingAgent.Tool.GrepTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_grep_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    File.write!(Path.join(tmp, "a.txt"), "apple\nbanana\ncherry\n")
    File.write!(Path.join(tmp, "b.txt"), "banana\ndragonfruit\n")
    File.write!(Path.join(tmp, "c.md"), "cherry pie\n")

    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  test "finds matches in files", %{dir: dir} do
    assert {:ok, result} = PiCodingAgent.Tool.Grep.call(%{pattern: "banana", path: dir}, %{})
    assert result =~ "a.txt"
    assert result =~ "b.txt"
  end

  test "finds no matches for missing pattern", %{dir: dir} do
    assert {:ok, result} = PiCodingAgent.Tool.Grep.call(%{pattern: "zzznotfound", path: dir}, %{})
    assert result == ""
  end

  test "filters by file pattern", %{dir: dir} do
    assert {:ok, result} = PiCodingAgent.Tool.Grep.call(%{pattern: "cherry", path: dir, file_pattern: "*.md"}, %{})
    assert result =~ "c.md"
    refute result =~ "a.txt"
  end
end
