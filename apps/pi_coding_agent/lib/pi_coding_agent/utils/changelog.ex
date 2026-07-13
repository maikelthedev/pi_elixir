defmodule PiCodingAgent.Utils.Changelog do
  @moduledoc "Changelog reading and parsing for version info."
  @changelog_path "CHANGELOG.md"

  def read(version \\ nil) do
    path = changelog_path()
    case File.read(path) do
      {:ok, content} -> {:ok, parse_changelog(content, version)}
      {:error, _} -> {:error, :not_found}
    end
  end

  def current_version do
    case read("Unreleased") do
      {:ok, entries} -> {:ok, entries}
      error -> error
    end
  end

  defp parse_changelog(content, nil), do: content
  defp parse_changelog(content, version) do
    lines = String.split(content, "\n")
    {_, result} = Enum.reduce(lines, {false, []}, fn
      "## [" <> vrest, {collecting, acc} ->
        version_match = String.starts_with?(vrest, version) or String.starts_with?(vrest, "Unreleased")
        {version_match, if(version_match, do: acc, else: [])}
      _line, {true, acc} -> {true, acc}
      _line, {false, acc} -> {false, acc}
    end)
    Enum.join(Enum.reverse(result), "\n")
  end

  defp changelog_path do
    case File.cwd!() do
      dir -> Path.join([dir, "apps", "pi_coding_agent", @changelog_path])
    end
  end
end
