defmodule PiTui.TerminalColorsTest do
  use ExUnit.Case, async: true
  test "fg returns 256-color code" do
    assert PiTui.TerminalColors.fg(99) =~ "38;5;99"
  end
  test "bg returns 256-color code" do
    assert PiTui.TerminalColors.bg(200) =~ "48;5;200"
  end
  test "rgb_fg returns truecolor code" do
    assert PiTui.TerminalColors.rgb_fg(255, 0, 0) =~ "38;2;255;0;0"
  end
  test "palette is a map" do
    assert is_map(PiTui.TerminalColors.palette())
  end
end
