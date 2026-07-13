defmodule PiCodingAgent.CacheStatsTest do
  use ExUnit.Case, async: true
  test "tracks hits and misses" do
    cs = PiCodingAgent.CacheStats.new("test") |> PiCodingAgent.CacheStats.hit() |> PiCodingAgent.CacheStats.miss()
    assert cs.hits == 1
    assert cs.misses == 1
    assert PiCodingAgent.CacheStats.ratio(cs) == 0.5
  end
end
