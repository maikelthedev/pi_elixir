defmodule PiCodingAgent.SessionManagerForkTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "fork creates new branch" do
    sm = PiCodingAgent.SessionManager.new()
    sm = PiCodingAgent.SessionManager.add_message(sm, %Message{role: :user, content: "hi"})
    {:ok, sm} = PiCodingAgent.SessionManager.fork(sm, :feature)
    assert {:ok, _} = PiCodingAgent.SessionManager.switch_branch(sm, :feature)
    assert length(PiCodingAgent.SessionManager.list_branches(sm)) == 2
  end
  test "switch_branch fails for unknown" do
    {:error, _} = PiCodingAgent.SessionManager.switch_branch(PiCodingAgent.SessionManager.new(), :nonexistent)
  end
end
