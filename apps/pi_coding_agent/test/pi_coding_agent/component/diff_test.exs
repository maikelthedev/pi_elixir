defmodule PiCodingAgent.Component.DiffTest do
  use ExUnit.Case, async: true
  test "renders added lines" do
    result = PiCodingAgent.Component.Diff.render("a", "a\nb")
    joined = Enum.join(result, "\n")
    assert joined =~ "+"
  end
  test "renders removed lines" do
    result = PiCodingAgent.Component.Diff.render("a\nb", "a")
    joined = Enum.join(result, "\n")
    assert joined =~ "-"
  end
end
