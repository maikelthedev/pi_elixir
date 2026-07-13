defmodule PiTui.Component.CancellableLoaderTest do
  use ExUnit.Case, async: true
  test "render produces output" do
    assert PiTui.Component.CancellableLoader.render("working") =~ "working"
  end
end
