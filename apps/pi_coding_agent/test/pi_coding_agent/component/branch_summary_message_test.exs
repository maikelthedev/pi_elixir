defmodule PiCodingAgent.Component.BranchSummaryMessageTest do
  use ExUnit.Case, async: true
  test "renders branch name" do
    result = PiCodingAgent.Component.BranchSummaryMessage.render("feature-x", "implemented Y")
    assert Enum.join(result) =~ "feature-x"
  end
end
