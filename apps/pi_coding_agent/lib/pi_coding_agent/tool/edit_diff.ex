defmodule PiCodingAgent.Tool.EditDiff do
  @moduledoc """
  Diff-based file edit tool. Applies a search/replace diff to a file.

  More precise than Edit — matches exact blocks including surrounding context.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{path: path, old_text: old_text, new_text: new_text} = args, _context) do
    case File.read(path) do
      {:ok, content} ->
        case apply_diff(content, old_text, new_text, args) do
          {:ok, new_content, changes} ->
            case File.write(path, new_content) do
              :ok -> {:ok, "Applied #{changes} change(s) to #{path}"}
              {:error, reason} -> {:error, "Error writing #{path}: #{reason}"}
            end
          {:error, reason} -> {:error, reason}
        end
      {:error, reason} -> {:error, "Error reading #{path}: #{reason}"}
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        path: %{type: "string", description: "Path to the file to edit"},
        old_text: %{type: "string", description: "Exact text block to replace"},
        new_text: %{type: "string", description: "Replacement text block"},
        count: %{type: "integer", description: "Number of occurrences to replace (default: 1, -1 for all)"}
      },
      required: [:path, :old_text, :new_text]
    }
  end

  defp apply_diff(content, old, new, args) do
    count = Map.get(args, :count, 1)

    case count do
      -1 ->
        # Replace all occurrences
        case String.contains?(content, old) do
          true ->
            new_content = String.replace(content, old, new)
            changes = count_occurrences(content, old)
            {:ok, new_content, changes}
          false ->
            {:error, "old_text not found in #{args[:path]}"}
        end

      n when n > 0 ->
        case String.split(content, old, parts: n + 1) do
          [before, after_rest] ->
            new_content = before <> new <> after_rest
            {:ok, new_content, 1}
          [_only] ->
            {:error, "old_text not found in #{args[:path]}"}
        end

      _ ->
        {:error, "Invalid count: #{count}"}
    end
  end

  defp count_occurrences(content, pattern) do
    content |> String.split(pattern) |> length() |> Kernel.-(1)
  end
end
