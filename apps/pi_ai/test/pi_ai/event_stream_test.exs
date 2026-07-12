defmodule PiAi.EventStreamTest do
  use ExUnit.Case, async: true

  describe "parse/1" do
    test "parses a simple SSE event" do
      sse = "data: {\"foo\": \"bar\"}\n\n"
      assert [%{"foo" => "bar"}] = PiAi.EventStream.parse(sse)
    end

    test "parses multiple events" do
      sse = "data: {\"a\": 1}\n\ndata: {\"b\": 2}\n\n"
      events = PiAi.EventStream.parse(sse)
      assert length(events) == 2
    end
  end

  describe "ingest/2" do
    test "handles complete events" do
      {events, rest} = PiAi.EventStream.ingest("", "data: {\"x\": 1}\n\n")
      assert length(events) == 1
      assert hd(events)["x"] == 1
      assert rest == ""
    end
  end

  describe "extract_text_openai/1" do
    test "extracts text from OpenAI streaming event" do
      event = %{"choices" => [%{"delta" => %{"content" => "Hello"}}]}
      assert PiAi.EventStream.extract_text_openai(event) == "Hello"
    end

    test "returns nil for non-text events" do
      event = %{"choices" => [%{"delta" => %{}}]}
      assert PiAi.EventStream.extract_text_openai(event) == nil
    end
  end

  describe "extract_text_anthropic/1" do
    test "extracts text from Anthropic streaming event" do
      event = %{"type" => "content_block_delta", "delta" => %{"text" => "Hello"}}
      assert PiAi.EventStream.extract_text_anthropic(event) == "Hello"
    end

    test "returns :done for stop events" do
      event = %{"type" => "message_stop"}
      assert PiAi.EventStream.extract_text_anthropic(event) == :done
    end
  end

  describe "accumulate/1" do
    test "accumulates text from stream chunks" do
      stream = [
        "data: {\"choices\": [{\"delta\": {\"content\": \"Hel\"}}]}\n\n",
        "data: {\"choices\": [{\"delta\": {\"content\": \"lo\"}}]}\n\n",
        "data: {\"choices\": [{\"delta\": {}}]}\n\n",
        "data: {\"choices\": [{\"finish_reason\": \"stop\"}]}\n\n"
      ]

      result = PiAi.EventStream.accumulate(stream)
      assert result["content"] == "Hello"
    end
  end
end
