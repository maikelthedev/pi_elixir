defmodule PiOrchestrator.IPC.ProtocolTest do
  use ExUnit.Case, async: true
  test "encode/decode request" do
    req = %{type: :spawn, cwd: "/tmp", label: "test"}
    encoded = PiOrchestrator.IPC.Protocol.encode(req)
    decoded = PiOrchestrator.IPC.Protocol.decode(encoded)
    assert decoded["type"] == "spawn"
    assert decoded["cwd"] == "/tmp"
  end
end
