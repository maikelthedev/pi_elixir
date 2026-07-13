defmodule PiAi.EventStreamEdgeTest do
  use ExUnit.Case, async: true
  test "handles empty input" do
    assert PiAi.EventStream.parse("") == []
  end
  test "handles DONE signal" do
    assert PiAi.EventStream.parse("data: [DONE]\n\n") == []
  end
  test "parses Anthropic event" do
    sse = "data: {\"type\":\"content_block_delta\",\"delta\":{\"text\":\"Hello\"}}\n\n"
    events = PiAi.EventStream.parse(sse)
    assert length(events) == 1
    assert PiAi.EventStream.extract_text_anthropic(hd(events)) == "Hello"
  end
end
