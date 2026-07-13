defmodule PiAi.Provider.OpenAIModelTest do
  use ExUnit.Case, async: true
  test "models returns gpt models" do
    models = PiAi.Provider.OpenAI.models()
    assert Enum.any?(models, &(&1.id =~ "gpt"))
  end
end
