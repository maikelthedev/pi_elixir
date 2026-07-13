defmodule PiAi.Provider.TogetherModelTest do
  use ExUnit.Case, async: true
  test "models returns together models" do
    models = PiAi.Provider.Together.models()
    assert length(models) >= 2
  end
end
