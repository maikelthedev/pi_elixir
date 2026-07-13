defmodule PiTui.Component.TextTest do
  use ExUnit.Case, async: true
  test "wrap splits long lines" do
    result = PiTui.Component.Text.wrap("hello world", 5)
    assert length(result) > 1
  end
  test "short text is unchanged" do
    assert PiTui.Component.Text.wrap("hi", 10) == ["hi"]
  end
  test "truncate adds ellipsis" do
    result = PiTui.Component.Text.truncate("hello world", 5)
    assert String.length(result) == 5
  end
end
