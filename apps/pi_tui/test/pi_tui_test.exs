defmodule PiTuiTest do
  use ExUnit.Case
  doctest PiTui

  test "greets the world" do
    assert PiTui.hello() == :world
  end
end
