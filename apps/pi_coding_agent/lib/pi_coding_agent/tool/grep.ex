defmodule PiCodingAgent.Tool.Grep do
  @moduledoc """
  Tool to search file contents with pattern matching.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{pattern: pattern, path: path} = args, _context) do
    file_pattern = Map.get(args, :file_pattern, "*")

    find_cmd = "find #{escape(path)} -name '#{file_pattern}' -type f 2>/dev/null"

    case System.cmd("sh", ["-c", find_cmd]) do
      {files, 0} when files != "" ->
        file_list = String.split(String.trim(files), "\n")
        results = search_files(pattern, file_list)
        {:ok, results}

      {_files, _exit_code} ->
        {:ok, ""}
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        pattern: %{type: "string", description: "Pattern to search for"},
        path: %{type: "string", description: "Directory path to search in"},
        file_pattern: %{type: "string", description: "File glob pattern (e.g., *.ex)", default: "*"}
      },
      required: [:pattern, :path]
    }
  end

  defp search_files(pattern, files) do
    files
    |> Enum.map(fn file ->
      case System.cmd("grep", ["-nH", pattern, file]) do
        {matches, 0} when matches != "" -> String.trim(matches)
        _ -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
    |> Enum.join("\n")
  end

  defp escape(path), do: String.replace(path, ~r/['\\]/, "\\\\\\0")
end
