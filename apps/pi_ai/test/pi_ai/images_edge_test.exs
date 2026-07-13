defmodule PiAi.ImagesEdgeTest do
  use ExUnit.Case, async: true
  test "generate without key returns error" do
    assert {:error, _} = PiAi.Images.generate("openrouter", "test prompt")
  end
end
