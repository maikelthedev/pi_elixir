defmodule PiTui.Component.BoxTest do
  use ExUnit.Case, async: true
  test "render creates bordered lines" do
    result = PiTui.Component.Box.render(["hello"], "", 20)
    assert length(result) == 3
  end
  test "render with title" do
    result = PiTui.Component.Box.render(["a"], "test", 20)
    assert length(result) == 3
  end
end
