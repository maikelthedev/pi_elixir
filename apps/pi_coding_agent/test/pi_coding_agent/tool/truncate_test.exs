defmodule PiCodingAgent.Tool.TruncateTest do
  use ExUnit.Case, async: true
  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_trunc_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp); on_exit(fn -> File.rm_rf!(tmp) end); %{dir: tmp}
  end
  test "truncates file", %{dir: dir} do
    path = Path.join(dir, "f.txt"); File.write!(path, "a\nb\nc\nd\ne")
    assert {:ok, _} = PiCodingAgent.Tool.Truncate.call(%{path: path, lines: 3}, %{})
    assert File.read!(path) == "a\nb\nc"
  end
end
