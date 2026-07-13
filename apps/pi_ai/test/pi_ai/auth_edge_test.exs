defmodule PiAi.AuthEdgeTest do
  use ExUnit.Case, async: true
  test "save and load preserves keys" do
    tmp = Path.join(System.tmp_dir!(), "pi_auth_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    PiAi.Auth.save("test_prov", %{"key" => "val"}, tmp)
    assert {:ok, %{"key" => "val"}} = PiAi.Auth.load("test_prov", tmp)
    File.rm_rf!(tmp)
  end
end
