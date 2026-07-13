defmodule PiAi.Utils.Hash do
  @moduledoc "Hashing utilities for content addressing and deduplication."
  def sha256(data) when is_binary(data) do
    :crypto.hash(:sha256, data) |> Base.encode16(case: :lower)
  end

  def sha1(data) when is_binary(data) do
    :crypto.hash(:sha, data) |> Base.encode16(case: :lower)
  end

  def md5(data) when is_binary(data) do
    :crypto.hash(:md5, data) |> Base.encode16(case: :lower)
  end

  def short_hash(data), do: sha256(data) |> binary_part(0, 12)

  def content_hash(map) when is_map(map) do
    map |> JSON.encode!() |> sha256()
  end
end
