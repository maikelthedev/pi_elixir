defmodule PiCodingAgent.Tool.Read do
  @moduledoc """
  Tool to read file contents with offset and limit support.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{path: path} = args, _context) do
    limit = Map.get(args, :limit, :all)
    offset = Map.get(args, :offset, 0)

    case File.read(path) do
      {:ok, content} ->
        lines = String.split(content, "\n", trim: false)

        result =
          if limit == :all do
            Enum.drop(lines, offset)
          else
            lines |> Enum.drop(offset) |> Enum.take(limit)
          end
          |> Enum.join("\n")

        {:ok, result}

      {:error, reason} ->
        {:error, "Error reading #{path}: #{reason}"}
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        path: %{type: "string", description: "Path to the file to read"},
        offset: %{type: "integer", description: "Line number to start reading from (0-indexed)", default: 0},
        limit: %{type: "integer", description: "Maximum number of lines to read"}
      },
      required: [:path]
    }
  end
end
