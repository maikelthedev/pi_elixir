defmodule PiCodingAgent.Component.StatusIndicatorTest do
  use ExUnit.Case, async: true
  test "idle returns green dot" do
    assert PiCodingAgent.Component.StatusIndicator.idle() =~ "●"
  end
  test "streaming returns spinner" do
    assert PiCodingAgent.Component.StatusIndicator.streaming(0) =~ "streaming"
  end
  test "error returns red" do
    assert PiCodingAgent.Component.StatusIndicator.error() =~ "error"
  end
end
