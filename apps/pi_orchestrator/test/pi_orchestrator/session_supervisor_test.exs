defmodule PiOrchestrator.SessionSupervisorTest do
  use ExUnit.Case, async: true
  test "start_link works" do
    {:ok, pid} = PiOrchestrator.SessionSupervisor.start_link(name: :test_ss)
    assert is_pid(pid)
  end
end
