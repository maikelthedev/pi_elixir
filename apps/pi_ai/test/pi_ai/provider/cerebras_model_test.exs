defmodule PiAi.Provider.CerebrasModelTest do
  use ExUnit.Case, async: true
  test "models returns cerebras models" do
    assert length(PiAi.Provider.Cerebras.models()) >= 1
  end
end
