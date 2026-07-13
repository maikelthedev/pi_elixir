defmodule PiCodingAgent.ProviderAttributionEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.ProviderAttribution)
  end
end
