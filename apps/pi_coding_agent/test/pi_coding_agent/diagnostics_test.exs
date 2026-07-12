defmodule PiCodingAgent.DiagnosticsTest do
  use ExUnit.Case, async: true

  describe "collect/0" do
    test "returns a map with diagnostic info" do
      info = PiCodingAgent.Diagnostics.collect()
      assert is_map(info)
      assert info["version"] == "0.1.0"
      assert is_list(info["providers"])
    end
  end
end
