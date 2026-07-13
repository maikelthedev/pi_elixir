defmodule PiTui.Component.LoaderTest do
  use ExUnit.Case, async: true
  test "frame returns spinner frames" do
    assert PiTui.Component.Loader.frame(0) != ""
    assert PiTui.Component.Loader.frame(1) != ""
  end
  test "render produces output" do
    assert PiTui.Component.Loader.render("loading") =~ "loading"
  end
end
