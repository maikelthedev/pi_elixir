defmodule PiTui.Component.SelectListTest do
  use ExUnit.Case, async: true

  describe "render/4" do
    test "renders a list of items" do
      result = PiTui.Component.SelectList.render(["a", "b", "c"], 0, 0, 10)
      assert result =~ "a"
      assert result =~ "b"
    end

    test "highlights selected item" do
      result = PiTui.Component.SelectList.render(["a", "b", "c"], 1, 0, 10)
      assert result =~ "b"
    end
  end
end
