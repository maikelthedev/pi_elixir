defmodule PiCodingAgent.Tool.Truncate do
  @moduledoc """
  Truncates a file to a given number of lines.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{path: path, lines: count}, _context) do
    case File.read(path) do
      {:ok, content} ->
        lines = content |> String.split("\n") |> Enum.take(count)
        truncated = Enum.join(lines, "\n")

        case File.write(path, truncated) do
          :ok -> {:ok, "Truncated #{path} to #{count} lines"}
          {:error, reason} -> {:error, "Error writing #{path}: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Error reading #{path}: #{reason}"}
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        path: %{type: "string", description: "Path to the file to truncate"},
        lines: %{type: "integer", description: "Number of lines to keep", default: 100}
      },
      required: [:path, :lines]
    }
  end
end
