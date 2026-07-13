defmodule PiCodingAgent.Component.ShowImagesSelectorTest do
  use ExUnit.Case, async: true
  test "renders enabled state" do
    assert PiCodingAgent.Component.ShowImagesSelector.render(true) =~ "ON"
  end
  test "renders disabled state" do
    assert PiCodingAgent.Component.ShowImagesSelector.render(false) =~ "OFF"
  end
end
