defmodule PiTui.Component.InputTest do
  use ExUnit.Case, async: true

  test "insert adds character at cursor" do
    input = PiTui.Component.Input.new() |> PiTui.Component.Input.insert("h") |> PiTui.Component.Input.insert("i")
    assert input.buffer == "hi"
    assert input.cursor == 2
  end

  test "delete removes character before cursor" do
    input = PiTui.Component.Input.new(buffer: "hello", cursor: 5) |> PiTui.Component.Input.delete()
    assert input.buffer == "hell"
    assert input.cursor == 4
  end

  test "submit returns text and resets buffer" do
    {new_input, text} = PiTui.Component.Input.new(buffer: "test") |> PiTui.Component.Input.submit()
    assert text == "test"
    assert new_input.buffer == ""
  end

  test "submit empty buffer returns nil" do
    {_input, nil} = PiTui.Component.Input.new() |> PiTui.Component.Input.submit()
  end

  test "cursor movement" do
    input = PiTui.Component.Input.new(buffer: "hello", cursor: 3)
    assert PiTui.Component.Input.cursor_left(input).cursor == 2
    result = input |> PiTui.Component.Input.cursor_right() |> PiTui.Component.Input.cursor_right()
    assert result.cursor == 5
  end

  test "history navigation" do
    input = PiTui.Component.Input.new(history: ["first", "second"])
    {input, text} = PiTui.Component.Input.submit(%{input | buffer: "third"})
    assert text == "third"
    assert length(input.history) == 3

    prev = PiTui.Component.Input.history_prev(input)
    prev2 = PiTui.Component.Input.history_prev(prev)
    assert prev2.buffer == "first"
  end
end
