defmodule PiCodingAgent.Component.ArminTest do
  use ExUnit.Case, async: true
  test "renders ASCII art" do
    assert PiCodingAgent.Component.Armin.render() |> Enum.join() =~ "pi agent"
  end
end
