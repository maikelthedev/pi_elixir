defmodule PiOrchestratorTest do
  use ExUnit.Case, async: true

  test "orchestrator module compiles" do
    assert is_pid(PiOrchestrator.start_link([]) |> elem(1))
  end
end
