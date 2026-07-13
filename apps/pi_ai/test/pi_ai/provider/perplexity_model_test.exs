defmodule PiAi.Provider.PerplexityModelTest do
  use ExUnit.Case, async: true
  test "models returns Perplexity models" do
    assert length(PiAi.Provider.Perplexity.models()) >= 1
  end
end
