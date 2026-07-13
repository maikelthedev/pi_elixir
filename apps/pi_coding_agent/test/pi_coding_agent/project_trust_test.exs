defmodule PiCodingAgent.ProjectTrustTest do
  use ExUnit.Case, async: true
  setup do
    tmp = Path.join(System.tmp_dir!(), "pi_trust_test_#{:erlang.system_time()}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)
    %{dir: tmp}
  end
  test "trust and untrust", %{dir: dir} do
    refute PiCodingAgent.ProjectTrust.trusted?(dir)
    PiCodingAgent.ProjectTrust.trust!(dir)
    assert PiCodingAgent.ProjectTrust.trusted?(dir)
    PiCodingAgent.ProjectTrust.untrust!(dir)
    refute PiCodingAgent.ProjectTrust.trusted?(dir)
  end
end
