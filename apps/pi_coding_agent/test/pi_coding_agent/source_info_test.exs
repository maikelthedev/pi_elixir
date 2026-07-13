defmodule PiCodingAgent.SourceInfoTest do
  use ExUnit.Case, async: true
  test "creates and formats source info" do
    si = PiCodingAgent.SourceInfo.new(:model, "gpt-4o", "config")
    assert PiCodingAgent.SourceInfo.format(si) =~ "gpt-4o"
  end
end
