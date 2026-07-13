defmodule PiTui.Component.SpacerTest do
  use ExUnit.Case, async: true
  test "lines returns blank strings" do
    assert PiTui.Component.Spacer.lines(3) == ["", "", ""]
  end
end
