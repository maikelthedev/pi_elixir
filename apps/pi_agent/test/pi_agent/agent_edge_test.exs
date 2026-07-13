defmodule PiAgent.AgentEdgeTest do
  use ExUnit.Case, async: true
  test "start with default opts" do
    m = %PiAi.Model{id: "t", name: "t", provider: "t", api: "t"}
    {:ok, pid} = PiAgent.Agent.start_link(model: m)
    assert is_pid(pid)
    Process.unlink(pid)
    Process.exit(pid, :kill)
  end
end
