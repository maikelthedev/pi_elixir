defmodule PiCodingAgent.ProjectTrustEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.ProjectTrust)
  end
end
