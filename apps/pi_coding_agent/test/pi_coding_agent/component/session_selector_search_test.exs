defmodule PiCodingAgent.Component.SessionSelectorSearchTest do
  use ExUnit.Case, async: true
  test "renders sessions" do
    sessions = [%{"session_id" => "test123", "messages" => [], "timestamp" => "2025-01-01"}]
    result = PiCodingAgent.Component.SessionSelectorSearch.render(sessions, "", 0)
    assert Enum.join(result) =~ "test123"
  end
end
