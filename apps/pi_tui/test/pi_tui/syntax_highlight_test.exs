defmodule PiTui.SyntaxHighlightTest do
  use ExUnit.Case, async: true
  test "highlights elixir keywords" do
    result = PiTui.SyntaxHighlight.highlight("defmodule Foo do", "elixir")
    assert length(result) == 1
    assert hd(result) =~ "defmodule"
  end
  test "highlights strings" do
    result = PiTui.SyntaxHighlight.highlight(~s(x = "hello"), "elixir")
    assert hd(result) =~ "hello"
  end
  test "returns lines for multi-line code" do
    result = PiTui.SyntaxHighlight.highlight("a\nb\nc", "elixir")
    assert length(result) == 3
  end
end
