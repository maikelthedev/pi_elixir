defmodule PiAi.Provider.HuggingFaceModelTest do
  use ExUnit.Case, async: true
  test "models returns HuggingFace models" do
    assert length(PiAi.Provider.HuggingFace.models()) >= 1
  end
end
