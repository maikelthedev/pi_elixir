defmodule PiCodingAgent.SettingsEdgeTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.Settings)
  end
end
