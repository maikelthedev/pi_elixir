defmodule PiAi.ModelRegistrySearchTest do
  use ExUnit.Case, async: true
  test "load and search" do
    PiAi.ModelRegistry.load()
    results = PiAi.ModelRegistry.search("gpt")
    assert is_list(results)
  end
end
