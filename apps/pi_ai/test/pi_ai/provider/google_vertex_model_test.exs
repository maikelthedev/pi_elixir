defmodule PiAi.Provider.GoogleVertexModelTest do
  use ExUnit.Case, async: true
  test "models returns Vertex AI models" do
    assert length(PiAi.Provider.GoogleVertex.models()) >= 1
  end
end
