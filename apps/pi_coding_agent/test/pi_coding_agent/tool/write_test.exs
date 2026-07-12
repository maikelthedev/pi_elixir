defmodule PiCodingAgent.Tool.WriteTest do
  use ExUnit.Case, async: true

  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_write_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end

  test "writes a new file" do
    assert {:ok, result} = PiCodingAgent.Tool.Write.call(%{path: "/tmp/pi_write_test_output.txt", content: "hello"}, %{})
    assert result =~ "written"
    assert File.read!("/tmp/pi_write_test_output.txt") == "hello"
  after
    File.rm("/tmp/pi_write_test_output.txt")
  end

  test "overwrites an existing file" do
    path = "/tmp/pi_write_test_overwrite.txt"
    File.write!(path, "old content")
    assert {:ok, _result} = PiCodingAgent.Tool.Write.call(%{path: path, content: "new content"}, %{})
    assert File.read!(path) == "new content"
  after
    File.rm("/tmp/pi_write_test_overwrite.txt")
  end
end
