defmodule PiCodingAgent.Mode.RPCTest do
  use ExUnit.Case, async: true
  test "ping returns pong" do
    assert PiCodingAgent.Mode.RPC.handle_request(%{"method" => "ping", "id" => 1})["result"] == "pong"
  end
  test "tools returns list" do
    result = PiCodingAgent.Mode.RPC.handle_request(%{"method" => "tools", "id" => 2})
    assert is_list(result["result"])
  end
  test "unknown method returns error" do
    result = PiCodingAgent.Mode.RPC.handle_request(%{"method" => "nope", "id" => 3})
    assert result["error"]
  end
end
