defmodule PiCodingAgent.Tool.Find do
  @moduledoc """
  Tool to find files matching a pattern.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{path: path} = args, _context) do
    pattern = Map.get(args, :pattern, "*")

    find_cmd = "find #{escape(path)} -name '#{pattern}' -type f 2>/dev/null | sort"

    case System.cmd("sh", ["-c", find_cmd]) do
      {result, _exit_code} ->
        trimmed = String.trim(result)
        if trimmed == "" do
          {:ok, ""}
        else
          {:ok, trimmed}
        end
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        path: %{type: "string", description: "Directory path to search"},
        pattern: %{type: "string", description: "File glob pattern (e.g., *.ex)", default: "*"}
      },
      required: [:path]
    }
  end

  defp escape(path), do: String.replace(path, ~R/['\\]/, "\\\\\\0")
end
