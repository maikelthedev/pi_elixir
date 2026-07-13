defmodule PiCodingAgent.ExportHTMLEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.ExportHTML)
  end
end
