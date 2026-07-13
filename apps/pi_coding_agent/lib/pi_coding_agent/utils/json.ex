defmodule PiCodingAgent.Utils.Json do
  @moduledoc "JSON utility functions."
  def pretty_encode(data, indent \\ 2) do
    case JSON.encode(data) do
      {:ok, json} -> json |> parse_and_format(indent)
      error -> error
    end
  end

  def safe_decode(input) do
    case JSON.decode(input) do
      {:ok, _} = result -> result
      {:error, _} -> {:error, :invalid_json}
    end
  end

  def deep_merge(base, override) when is_map(base) and is_map(override) do
    Map.merge(base, override, fn
      _key, v1, v2 when is_map(v1) and is_map(v2) -> deep_merge(v1, v2)
      _key, _v1, v2 -> v2
    end)
  end

  defp parse_and_format(json, _indent), do: json
end
