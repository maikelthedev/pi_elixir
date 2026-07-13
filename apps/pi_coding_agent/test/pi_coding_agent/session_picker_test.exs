defmodule PiCodingAgent.SessionPickerTest do
  use ExUnit.Case, async: true
  test "pick returns cancel when no sessions" do
    assert PiCodingAgent.SessionPicker.pick() == {:cancel, "No saved sessions"}
  end
end
