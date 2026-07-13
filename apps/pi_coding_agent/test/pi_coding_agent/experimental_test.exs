defmodule PiCodingAgent.ExperimentalTest do
  use ExUnit.Case, async: true
  test "returns false for unknown features" do
    refute PiCodingAgent.Experimental.enabled?(:nonexistent)
  end
  test "lists all features" do
    features = PiCodingAgent.Experimental.list()
    assert is_map(features)
  end
end
