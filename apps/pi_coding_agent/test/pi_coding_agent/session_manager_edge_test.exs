defmodule PiCodingAgent.SessionManagerEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.SessionManager)
  end
end
