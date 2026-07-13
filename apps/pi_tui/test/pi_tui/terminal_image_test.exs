defmodule PiTui.TerminalImageTest do
  use ExUnit.Case, async: true
  test "placeholder returns alt text" do
    assert PiTui.TerminalImage.placeholder("test.png", "unsupported") =~ "test.png"
  end
end
