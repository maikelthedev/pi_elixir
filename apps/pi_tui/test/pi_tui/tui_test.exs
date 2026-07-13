defmodule PiTui.TUITest do
  use ExUnit.Case, async: true
  test "new creates TUI" do
    tui = PiTui.TUI.new()
    assert tui.height > 0
    assert tui.width > 0
  end
end
