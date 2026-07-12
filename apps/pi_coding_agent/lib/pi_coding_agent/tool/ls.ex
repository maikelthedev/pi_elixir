defmodule PiCodingAgent.Tool.Ls do
  @moduledoc """
  Tool to list directory contents.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{path: path}, _context) do
    case File.ls(path) do
      {:ok, entries} ->
        formatted =
          entries
          |> Enum.map(fn entry ->
            full = Path.join(path, entry)
            suffix = if File.dir?(full), do: "/", else: ""
            "#{entry}#{suffix}"
          end)
          |> Enum.sort()
          |> Enum.join("\n")

        {:ok, formatted}

      {:error, reason} ->
        {:error, "Error listing #{path}: #{reason}"}
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        path: %{type: "string", description: "Directory path to list"}
      },
      required: [:path]
    }
  end
end
