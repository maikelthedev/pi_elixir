defmodule PiAi.Provider.BedrockModelTest do
  use ExUnit.Case, async: true
  test "models returns Bedrock models" do
    assert length(PiAi.Provider.Bedrock.models()) >= 1
  end
end
