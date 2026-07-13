defmodule PiCodingAgent.Component.VisualTruncateTest do
  use ExUnit.Case, async: true
  test "renders truncation notice" do
    result = PiCodingAgent.Component.VisualTruncate.render(100, 10)
    assert result =~ "90 more"
  end
  test "returns empty when under limit" do
    assert PiCodingAgent.Component.VisualTruncate.render(5, 10) == ""
  end
end
