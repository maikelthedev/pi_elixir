defmodule PiCodingAgent.Component.KeybindingHintsTest do
  use ExUnit.Case, async: true
  test "renders shortcuts" do
    result = PiCodingAgent.Component.KeybindingHints.render()
    assert Enum.join(result) =~ "Ctrl+C"
  end
end
