defmodule PiCodingAgent.Component.SessionSelectorTest do
  use ExUnit.Case, async: true
  test "renders sessions" do
    sessions = [%{"session_id" => "s1", "messages" => [1,2], "timestamp" => "2025-01-01", "model" => "gpt"}]
    result = PiCodingAgent.Component.SessionSelector.render(sessions, 0)
    assert Enum.join(result) =~ "s1"
  end
end
