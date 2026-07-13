defmodule PiTui.Component.TruncatedTextTest do
  use ExUnit.Case, async: true
  test "short text unchanged" do
    assert PiTui.Component.TruncatedText.render("hello", 10) == "hello"
  end
  test "long text truncated" do
    result = PiTui.Component.TruncatedText.render("hello world", 5)
    assert String.length(result) == 5
  end
  test "render_lines truncates" do
    result = PiTui.Component.TruncatedText.render_lines(["a","b","c"], 2)
    assert length(result) == 3
  end
end
