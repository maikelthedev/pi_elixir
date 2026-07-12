defmodule PiCodingAgentTest do
  use ExUnit.Case
  doctest PiCodingAgent

  test "greets the world" do
    assert PiCodingAgent.hello() == :world
  end
end
