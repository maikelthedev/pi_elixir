defmodule PiAi.Provider.GroqModelTest do
  use ExUnit.Case, async: true
  test "models returns groq models" do
    models = PiAi.Provider.Groq.models()
    assert length(models) >= 2
  end
end
