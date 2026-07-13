defmodule PiCodingAgent.ResourceLoaderTest do
  use ExUnit.Case, async: true
  test "returns dirs structure" do
    dirs = PiCodingAgent.ResourceLoader.dirs()
    assert Map.has_key?(dirs, :global)
    assert Map.has_key?(dirs, :project)
  end
  test "ensure_dirs creates paths" do
    tmp = Path.join(System.tmp_dir!(), "pi_res_test_#{:erlang.system_time()}")
    PiCodingAgent.ResourceLoader.ensure_dirs!(tmp)
    assert File.exists?(Path.join(tmp, ".pi"))
    File.rm_rf!(tmp)
  end
end
