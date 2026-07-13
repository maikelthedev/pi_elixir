defmodule PiCodingAgent.OAuthEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.OAuth)
  end
end
