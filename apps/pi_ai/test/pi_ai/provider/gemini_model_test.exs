defmodule PiAi.Provider.GeminiModelTest do
  use ExUnit.Case, async: true
  test "models returns gemini models" do
    models = PiAi.Provider.Gemini.models()
    assert Enum.any?(models, &(&1.id =~ "gemini"))
  end
end
