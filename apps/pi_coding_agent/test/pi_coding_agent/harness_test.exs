defmodule PiCodingAgent.HarnessTest do
  use ExUnit.Case, async: true
  test "new creates harness" do
    h = PiCodingAgent.Harness.new()
    assert h.running == false
  end
  test "start and stop" do
    h = PiCodingAgent.Harness.new() |> PiCodingAgent.Harness.start()
    assert h.running == true
    h = PiCodingAgent.Harness.stop(h)
    assert h.running == false
  end
end
