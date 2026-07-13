defmodule PiAi.Provider.OpenRouterModelTest do
  use ExUnit.Case, async: true
  test "models returns OpenRouter models" do
    assert length(PiAi.Provider.OpenRouter.models()) >= 1
  end
end
