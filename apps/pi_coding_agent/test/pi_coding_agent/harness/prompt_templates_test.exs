defmodule PiCodingAgent.Harness.PromptTemplatesTest do
  use ExUnit.Case, async: true
  test "list returns templates" do
    assert length(PiCodingAgent.Harness.PromptTemplates.list()) > 0
  end
  test "render fills template" do
    {:ok, result} = PiCodingAgent.Harness.PromptTemplates.render(:explain, %{"input" => "hello"})
    assert result =~ "hello"
  end
end
