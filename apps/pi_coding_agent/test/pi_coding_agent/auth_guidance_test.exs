defmodule PiCodingAgent.AuthGuidanceTest do
  use ExUnit.Case, async: true
  test "returns guidance for known providers" do
    assert PiCodingAgent.AuthGuidance.message("anthropic") =~ "ANTHROPIC_API_KEY"
    assert PiCodingAgent.AuthGuidance.message("openai") =~ "OPENAI_API_KEY"
  end
end
