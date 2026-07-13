defmodule PiAi.Provider.MoonshotAIModelTest do
  use ExUnit.Case, async: true
  test "models returns Moonshot models" do
    assert length(PiAi.Provider.MoonshotAI.models()) >= 1
  end
end
