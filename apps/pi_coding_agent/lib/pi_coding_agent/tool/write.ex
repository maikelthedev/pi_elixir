defmodule PiCodingAgent.Tool.Write do
  @moduledoc """
  Tool to write content to a file, creating or overwriting.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{path: path, content: content}, _context) do
    dir = Path.dirname(path)

    case File.mkdir_p(dir) do
      :ok ->
        case File.write(path, content) do
          :ok -> {:ok, "File written to #{path}"}
          {:error, reason} -> {:error, "Error writing to #{path}: #{reason}"}
        end

      {:error, reason} ->
        {:error, "Error creating directory #{dir}: #{reason}"}
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        path: %{type: "string", description: "Path to the file to write"},
        content: %{type: "string", description: "Content to write to the file"}
      },
      required: [:path, :content]
    }
  end
end
