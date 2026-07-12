defmodule PiOrchestratorTest do
  use ExUnit.Case
  doctest PiOrchestrator

  test "greets the world" do
    assert PiOrchestrator.hello() == :world
  end
end
