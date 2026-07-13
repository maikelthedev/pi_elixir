defmodule PiCodingAgent.Mode.RPCModuleTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.Mode.RPC)
  end
end
