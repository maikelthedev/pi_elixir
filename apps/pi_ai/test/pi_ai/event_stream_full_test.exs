defmodule PiAi.EventStreamFullTest do
  use ExUnit.Case, async: true
  test "accumulate complete OpenAI stream" do
    chunks = [
      "data: {\"choices\": [{\"delta\": {\"content\": \"Hello\"}}]}\n\n",
      "data: {\"choices\": [{\"delta\": {\"content\": \" world\"}}]}\n\n",
      "data: {\"choices\": [{\"finish_reason\": \"stop\"}]}\n\n"
    ]
    result = PiAi.EventStream.accumulate(chunks)
    assert result["content"] == "Hello world"
  end
  test "accumulate with tool calls" do
    chunks = [
      "data: {\"choices\": [{\"delta\": {\"content\": \"\"}}]}\n\n",
      "data: {\"choices\": [{\"delta\": {\"tool_calls\": [{\"index\": 0, \"id\": \"c1\", \"function\": {\"name\": \"read\", \"arguments\": \"\"}}]}}]}\n\n",
      "data: {\"choices\": [{\"delta\": {\"tool_calls\": [{\"index\": 0, \"function\": {\"arguments\": \"{\\\"path\\\":\\\"f\\\"}\"}}]}}]}\n\n",
      "data: {\"choices\": [{\"finish_reason\": \"tool_calls\"}]}\n\n"
    ]
    result = PiAi.EventStream.accumulate(chunks)
    assert length(result["tool_calls"]) > 0
  end
end
