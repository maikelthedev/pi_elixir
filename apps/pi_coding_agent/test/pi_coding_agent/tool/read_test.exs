defmodule PiCodingAgent.Tool.ReadTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_read_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    File.write!(Path.join(tmp, "hello.txt"), "hello world\nline 2\nline 3\nline 4\nline 5\n")

    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  test "reads a file", %{dir: dir} do
    path = Path.join(dir, "hello.txt")
    assert {:ok, result} = PiCodingAgent.Tool.Read.call(%{path: path}, %{})
    assert result =~ "hello world"
    assert result =~ "line 5"
  end

  test "respects limit option", %{dir: dir} do
    path = Path.join(dir, "hello.txt")
    assert {:ok, result} = PiCodingAgent.Tool.Read.call(%{path: path, limit: 2}, %{})
    assert result =~ "hello world"
    assert result =~ "line 2"
    refute result =~ "line 3"
  end

  test "respects offset option", %{dir: dir} do
    path = Path.join(dir, "hello.txt")
    assert {:ok, result} = PiCodingAgent.Tool.Read.call(%{path: path, offset: 3}, %{})
    assert result =~ "line 4"
    refute result =~ "hello world"
  end

  test "returns error for missing file" do
    assert {:error, _} = PiCodingAgent.Tool.Read.call(%{path: "/nonexistent/file.txt"}, %{})
  end
end
