defmodule PiCodingAgent.Component.DynamicBorderTest do
  use ExUnit.Case, async: true
  test "renders with title" do
    result = PiCodingAgent.Component.DynamicBorder.render("title", :normal, 30)
    assert hd(result) =~ "title"
  end
  test "renders all modes" do
    for mode <- [:normal, :error, :success, :warning] do
      assert length(PiCodingAgent.Component.DynamicBorder.render("test", mode, 20)) == 1
    end
  end
end
