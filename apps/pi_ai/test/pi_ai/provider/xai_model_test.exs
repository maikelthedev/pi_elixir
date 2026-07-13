defmodule PiAi.Provider.XAIModelTest do
  use ExUnit.Case, async: true
  test "models returns xAI models" do
    assert length(PiAi.Provider.XAI.models()) >= 1
  end
end
