defmodule PiCodingAgent.PackageManagerTest do
  use ExUnit.Case, async: true
  test "list returns ok" do
    assert PiCodingAgent.PackageManager.handle_command(["list"]) == :ok
  end
  test "unknown command shows help" do
    assert PiCodingAgent.PackageManager.handle_command(["bogus"]) == :ok
  end
end
