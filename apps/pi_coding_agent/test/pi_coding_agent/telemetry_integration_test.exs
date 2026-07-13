defmodule PiCodingAgent.TelemetryIntegrationTest do
  use ExUnit.Case, async: true
  test "report without eventbus" do
    assert PiCodingAgent.Telegraf.report() == :ok
  end
  test "timing and report" do
    t = PiCodingAgent.Telemetry.new()
    t = PiCodingAgent.Telemetry.timing(t, "op", 100)
    t = PiCodingAgent.Telemetry.timing(t, "op", 200)
    r = PiCodingAgent.Telemetry.report(t)
    assert r =~ "op"
  end
end
