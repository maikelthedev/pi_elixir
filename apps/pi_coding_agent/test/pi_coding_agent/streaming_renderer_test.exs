defmodule PiCodingAgent.StreamingRendererTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.StreamingRenderer)
  end
end
