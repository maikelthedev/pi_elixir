defmodule PiCodingAgent.Component.CustomEditorTest do
  use ExUnit.Case, async: true
  test "renders code lines" do
    result = PiCodingAgent.Component.CustomEditor.render(["line1", "line2"], 0, 0, 0, 10)
    assert Enum.join(result) =~ "line1"
  end
end
