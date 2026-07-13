defmodule PiCodingAgent.TelemetryTest do
  use ExUnit.Case, async: true
  test "records and reports timings" do
    telem = PiCodingAgent.Telemetry.new()
    telem = PiCodingAgent.Telemetry.timing(telem, "test_op", 150)
    telem = PiCodingAgent.Telemetry.timing(telem, "test_op", 50)
    assert PiCodingAgent.Telemetry.avg(telem, "test_op") == 100
  end
  test "records token usage" do
    telem = PiCodingAgent.Telemetry.new() |> PiCodingAgent.Telemetry.record_tokens(500) |> PiCodingAgent.Telemetry.record_tokens(300)
    report = PiCodingAgent.Telemetry.report(telem)
    assert report =~ "800"
  end
end
