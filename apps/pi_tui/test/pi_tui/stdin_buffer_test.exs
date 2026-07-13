defmodule PiTui.StdinBufferTest do
  use ExUnit.Case, async: true
  test "new creates empty buffer" do
    sb = PiTui.StdinBuffer.new()
    refute PiTui.StdinBuffer.has_pending?(sb)
  end
  test "feed parses bytes" do
    sb = PiTui.StdinBuffer.new()
    {_sb, key} = PiTui.StdinBuffer.feed(sb, "\n")
    assert key == :enter or key == {:char, 10}
  end
end
