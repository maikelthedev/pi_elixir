defmodule PiCodingAgent.OutputGuardTest do
  use ExUnit.Case, async: true
  test "take_over and restore" do
    assert PiCodingAgent.OutputGuard.take_over!() == :ok
    assert PiCodingAgent.OutputGuard.restore!() == :ok
  end
end
