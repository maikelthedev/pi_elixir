defmodule PiCodingAgent.ProviderDisplayNamesTest do
  use ExUnit.Case, async: true
  test "returns known names" do
    assert PiCodingAgent.ProviderDisplayNames.name("anthropic") == "Anthropic"
    assert PiCodingAgent.ProviderDisplayNames.name("openai") == "OpenAI"
  end
  test "falls back to id for unknown" do
    assert PiCodingAgent.ProviderDisplayNames.name("unknown-xyz") == "unknown-xyz"
  end
end
