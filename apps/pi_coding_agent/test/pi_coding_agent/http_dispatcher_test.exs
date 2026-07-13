defmodule PiCodingAgent.HTTPDispatcherTest do
  use ExUnit.Case, async: true
  test "config returns proxy settings from env" do
    config = PiCodingAgent.HTTPDispatcher.config()
    assert is_map(config)
    assert Map.has_key?(config, :http_proxy)
  end
end
