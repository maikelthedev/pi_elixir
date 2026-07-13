defmodule PiCodingAgent.Utils.VersionCheck do
  @moduledoc "Version checking for updates."
  @spec check(String.t()) :: {:ok, map()} | {:error, term()}
  def check(current_version) do
    case fetch_latest_version() do
      {:ok, latest} ->
        {:ok, %{
          current: current_version,
          latest: latest,
          update_available: version_gt?(latest, current_version)
        }}
      error -> error
    end
  end

  def update_message(current, latest) do
    if version_gt?(latest, current) do
      "Update available: #{current} -> #{latest}. Run: npm update -g pi-coding-agent"
    else
      "You are running the latest version: #{current}"
    end
  end

  defp fetch_latest_version do
    case HTTPClient.get("https://registry.npmjs.org/pi-coding-agent/latest") do
      {:ok, body} ->
        case JSON.decode(body) do
          {:ok, %{"version" => version}} -> {:ok, version}
          _ -> {:error, :parse_error}
        end
      error -> error
    end
  end

  defp version_gt?(v1, v2) do
    v1_parts = String.split(v1, ".") |> Enum.map(&parse_int/1)
    v2_parts = String.split(v2, ".") |> Enum.map(&parse_int/1)
    v1_parts > v2_parts
  end

  defp parse_int(s), do: Integer.parse(s) |> elem(0)
end
