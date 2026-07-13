defmodule PiCodingAgent.SessionSelectorEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.SessionSelector)
  end
end
