defmodule PiOrchestrator.RpcProcessTest do
  use ExUnit.Case, async: true
  test "generates id" do
    id = :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
    assert is_binary(id)
    assert String.length(id) == 12
  end
end
