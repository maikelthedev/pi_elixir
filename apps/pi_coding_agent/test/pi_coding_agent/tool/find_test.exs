defmodule PiCodingAgent.Tool.FindTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_find_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    File.write!(Path.join(tmp, "readme.md"), "docs")

    lib = Path.join(tmp, "lib")
    sub = Path.join(lib, "sub")
    File.mkdir_p!(sub)
    File.write!(Path.join(lib, "app.ex"), "code")
    File.write!(Path.join(sub, "helper.ex"), "helper")

    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  test "finds files matching pattern", %{dir: dir} do
    assert {:ok, result} = PiCodingAgent.Tool.Find.call(%{pattern: "*.ex", path: dir}, %{})
    assert result =~ "app.ex"
    assert result =~ "helper.ex"
  end

  test "finds all files without pattern filter", %{dir: dir} do
    assert {:ok, result} = PiCodingAgent.Tool.Find.call(%{path: dir}, %{})
    assert result =~ "readme.md"
    assert result =~ "app.ex"
  end
end
