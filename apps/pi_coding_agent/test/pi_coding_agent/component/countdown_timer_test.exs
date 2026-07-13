defmodule PiCodingAgent.Component.CoundtownTimerTest do
  use ExUnit.Case, async: true
  test "renders timer" do
    assert PiCodingAgent.Component.CountdownTimer.render(30) =~ "30s"
  end
end
