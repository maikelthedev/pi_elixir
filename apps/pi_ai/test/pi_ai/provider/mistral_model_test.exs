defmodule PiAi.Provider.MistralModelTest do
  use ExUnit.Case, async: true
  test "models returns mistral models" do
    models = PiAi.Provider.Mistral.models()
    assert length(models) >= 2
  end
end
