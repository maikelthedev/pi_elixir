defmodule PiAgentTest do
  use ExUnit.Case
  doctest PiAgent

  test "greets the world" do
    assert PiAgent.hello() == :world
  end
end
