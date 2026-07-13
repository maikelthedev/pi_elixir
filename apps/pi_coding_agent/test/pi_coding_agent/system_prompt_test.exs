defmodule PiCodingAgent.SystemPromptTest do
  use ExUnit.Case, async: true
  test "builds system prompt with model" do
    prompt = PiCodingAgent.SystemPrompt.build(model: "gpt-4o")
    assert prompt =~ "gpt-4o"
    assert prompt =~ "coding agent"
  end
  test "includes skills when provided" do
    prompt = PiCodingAgent.SystemPrompt.build(skills: ["elixir"])
    assert prompt =~ "elixir"
  end
end
