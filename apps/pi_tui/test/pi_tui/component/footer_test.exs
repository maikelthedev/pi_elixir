defmodule PiTui.Component.FooterTest do
  use ExUnit.Case, async: true
  test "render produces output" do
    result = PiTui.Component.Footer.render(model: "test-model", status: :idle, messages: 5)
    assert result =~ "test-model"
  end
  test "status_line returns styled text" do
    assert PiTui.Component.Footer.status_line("hello") =~ "hello"
  end
end
