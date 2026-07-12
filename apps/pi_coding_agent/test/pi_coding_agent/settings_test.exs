defmodule PiCodingAgent.SettingsTest do
  use ExUnit.Case, async: true

  describe "get/3" do
    test "returns default when key missing" do
      assert PiCodingAgent.Settings.get("nonexistent_key_xyz", "fallback") == "fallback"
    end
  end

  describe "load/1" do
    test "returns a map" do
      settings = PiCodingAgent.Settings.load()
      assert is_map(settings)
    end
  end
end
