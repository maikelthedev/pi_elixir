defmodule PiCodingAgent.SessionCwdEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.SessionCwd)
  end
end
