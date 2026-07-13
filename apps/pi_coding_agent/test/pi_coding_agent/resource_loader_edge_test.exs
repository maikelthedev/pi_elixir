defmodule PiCodingAgent.ResourceLoaderEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.ResourceLoader)
  end
end
