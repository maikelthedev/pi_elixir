defmodule PiCodingAgent.CacheStats do
  @moduledoc "Cache hit/miss statistics for session and model caches."
  defstruct [:cache_name, hits: 0, misses: 0, size: 0]
  def new(name), do: %__MODULE__{cache_name: name}
  def hit(%__MODULE__{hits: h} = cs), do: %{cs | hits: h + 1}
  def miss(%__MODULE__{misses: m} = cs), do: %{cs | misses: m + 1}
  def ratio(%__MODULE__{hits: h, misses: m}) do
    total = h + m
    if total > 0, do: h / total, else: 0.0
  end
  def report(%__MODULE__{cache_name: n, hits: h, misses: m, size: s}) do
    "#{n}: #{h} hits, #{m} misses, #{s} entries, #{Float.round(ratio(%__MODULE__{hits: h, misses: m}) * 100, 1)}% hit rate"
  end
end
