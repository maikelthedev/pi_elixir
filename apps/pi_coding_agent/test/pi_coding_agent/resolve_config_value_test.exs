defmodule PiCodingAgent.ResolveConfigValueTest do
  use ExUnit.Case, async: true
  test "returns value as-is" do
    assert PiCodingAgent.ResolveConfigValue.resolve("hello") == "hello"
  end
  test "returns default for nil" do
    assert PiCodingAgent.ResolveConfigValue.resolve(nil, "default") == "default"
  end
end
