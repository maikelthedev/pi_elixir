defmodule PiCodingAgent.Component.CompactionSummaryTest do
  use ExUnit.Case, async: true
  test "renders summary text" do
    result = PiCodingAgent.Component.CompactionSummary.render("compacted 50 messages")
    assert Enum.join(result) =~ "compacted"
  end
end
