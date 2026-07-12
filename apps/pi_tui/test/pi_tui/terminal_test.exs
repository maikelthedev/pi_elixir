defmodule PiTui.TerminalTest do
  use ExUnit.Case, async: true

  describe "size/0" do
    test "returns a tuple of {rows, cols}" do
      {rows, cols} = PiTui.Terminal.size()
      assert is_integer(rows) and rows > 0
      assert is_integer(cols) and cols > 0
    end
  end

  describe "ANSI escape helpers" do
    test "clear_screen/0 returns the escape sequence" do
      assert PiTui.Terminal.clear_screen() == "\e[2J\e[H"
    end

    test "cursor_up/1 returns proper escape" do
      assert PiTui.Terminal.cursor_up(3) == "\e[3A"
    end

    test "cursor_down/1 returns proper escape" do
      assert PiTui.Terminal.cursor_down(5) == "\e[5B"
    end

    test "cursor_forward/1 returns proper escape" do
      assert PiTui.Terminal.cursor_forward(10) == "\e[10C"
    end

    test "cursor_backward/1 returns proper escape" do
      assert PiTui.Terminal.cursor_backward(4) == "\e[4D"
    end

    test "hide_cursor/0 and show_cursor/0" do
      assert PiTui.Terminal.hide_cursor() == "\e[?25l"
      assert PiTui.Terminal.show_cursor() == "\e[?25h"
    end

    test "set_style/1 returns proper SGR codes" do
      assert PiTui.Terminal.set_style(:bold) == "\e[1m"
      assert PiTui.Terminal.set_style(:dim) == "\e[2m"
      assert PiTui.Terminal.set_style(:underline) == "\e[4m"
      assert PiTui.Terminal.reset_style() == "\e[0m"
    end

    test "color codes are correct" do
      assert PiTui.Terminal.set_style(:green) == "\e[32m"
      assert PiTui.Terminal.set_style(:red) == "\e[31m"
      assert PiTui.Terminal.set_style(:yellow) == "\e[33m"
      assert PiTui.Terminal.set_style(:blue) == "\e[34m"
      assert PiTui.Terminal.set_style(:cyan) == "\e[36m"
    end
  end
end
