defmodule PiAi.Provider.FireworksModelTest do
  use ExUnit.Case, async: true
  test "models returns fireworks models" do
    models = PiAi.Provider.Fireworks.models()
    assert length(models) >= 2
  end
end
