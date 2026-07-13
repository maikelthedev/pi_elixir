defmodule PiAgent.ProxyTest do
  use ExUnit.Case, async: true
  test "new creates struct" do
    p = PiAgent.Proxy.new(server_url: "http://localhost:8080")
    assert p.server_url == "http://localhost:8080"
    assert p.timeout == 30_000
  end
end
