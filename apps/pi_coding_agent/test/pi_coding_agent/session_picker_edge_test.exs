defmodule PiCodingAgent.SessionPickerEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.SessionPicker)
  end
end
