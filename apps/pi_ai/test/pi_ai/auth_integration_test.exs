defmodule PiAi.AuthIntegrationTest do
  use ExUnit.Case, async: true

  describe "load/1 integration" do
    test "handles missing auth file gracefully" do
      assert {:ok, nil} = PiAi.Auth.load("nonexistent_provider_xyz")
    end
  end
end
