defmodule PiCodingAgent.Tool.Edit do
  @moduledoc """
  Tool to make precise text replacements in files.

  Uses exact text matching to find and replace content.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{path: path, old_text: old_text, new_text: new_text}, _context) do
    case File.read(path) do
      {:ok, content} ->
        case String.split(content, old_text, parts: 2) do
          [before, rest] ->
            new_content = before <> new_text <> rest

            case File.write(path, new_content) do
              :ok ->
                {:ok, "Successfully replaced text in #{path}"}

              {:error, reason} ->
                {:error, "Error writing to #{path}: #{reason}"}
            end

          [_only] ->
            {:error, "Could not find old_text in #{path}"}
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
        path: %{type: "string", description: "Path to the file to edit"},
        old_text: %{type: "string", description: "Exact text to find and replace"},
        new_text: %{type: "string", description: "Replacement text"}
      },
      required: [:path, :old_text, :new_text]
    }
  end
end
