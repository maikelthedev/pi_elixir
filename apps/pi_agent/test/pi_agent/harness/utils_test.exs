defmodule PiAgent.Harness.UtilsTest do
  use ExUnit.Case, async: true
  alias PiAgent.Harness.Utils

  test "truncate short text unchanged" do
    assert Utils.truncate("hi", 100) == "hi"
  end

  test "truncate long text is cut" do
    result = Utils.truncate(String.duplicate("x", 200), 100)
    assert String.length(result) < 200
    assert result =~ "truncated"
  end

  test "truncate_lines" do
    text = (1..50) |> Enum.map(&"line #{&1}") |> Enum.join("\n")
    result = Utils.truncate_lines(text, 10)
    assert result =~ "more lines"
  end

  test "escape_ansi removes color codes" do
    text = "\e[31mred\e[0m"
    assert Utils.escape_ansi(text) == "red"
  end

  test "word_wrap wraps long lines" do
    result = Utils.word_wrap(String.duplicate("a", 100), 50)
    lines = String.split(result, "\n")
    assert length(lines) > 1
  end

  test "shell_output trims trailing whitespace" do
    assert Utils.shell_output("hello\n\n\n") == "hello"
  end

  test "truncate_tokens" do
    long = String.duplicate("x", 10000)
    assert Utils.truncate_tokens(long, 100) |> String.length() < 10000
  end
end
