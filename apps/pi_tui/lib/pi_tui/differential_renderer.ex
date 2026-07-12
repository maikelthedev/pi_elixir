defmodule PiTui.DifferentialRenderer do
  @moduledoc """
  Efficient terminal renderer that only outputs changed lines.

  Tracks the previous screen buffer and computes a minimal set of
  ANSI escape sequences to update only the rows that changed.
  """

  defstruct [:height, buffer: []]

  @type t :: %__MODULE__{
          height: pos_integer(),
          buffer: [String.t()]
        }

  @doc """
  Creates a new DifferentialRenderer with the given height in rows.
  """
  @spec new(pos_integer()) :: t()
  def new(height) when height > 0 do
    %__MODULE__{height: height}
  end

  @doc """
  Renders new lines, returning `{updated_renderer, ansi_output}`.

  First call outputs all lines. Subsequent calls only output
  the lines that changed, with cursor positioning.
  """
  @spec render(t(), [String.t()]) :: {t(), String.t()}
  def render(renderer, lines) do
    padded = Enum.map(lines, & &1) |> pad_to(renderer.height)

    if renderer.buffer == [] do
      # First render: output all lines with clear-to-end-of-line
      output =
        padded
        |> Enum.with_index(1)
        |> Enum.map(fn {line, idx} ->
          prefix = if idx == 1, do: "\e[H", else: ""
          "#{prefix}#{line}\e[0K"
        end)
        |> Enum.join("\n")

      {%{renderer | buffer: padded}, output}
    else
      # Subsequent renders: find changed lines
      diffs =
        Enum.zip(padded, renderer.buffer)
        |> Enum.with_index(1)
        |> Enum.reduce([], fn {{new, old}, idx}, acc ->
          if new != old do
            acc ++ [{idx, new}]
          else
            acc
          end
        end)

      # If only some lines changed, use cursor positioning
      output =
        if length(diffs) <= renderer.height do
          diffs
          |> Enum.map(fn {idx, line} ->
            "\e[#{idx};1H#{line}\e[0K"
          end)
          |> Enum.join("\n")
        else
          # Too many changes: full redraw
          padded
          |> Enum.with_index(1)
          |> Enum.map(fn {line, idx} ->
            prefix = if idx == 1, do: "\e[H", else: ""
            "#{prefix}#{line}\e[0K"
          end)
          |> Enum.join("\n")
        end

      {%{renderer | buffer: padded}, output}
    end
  end

  defp pad_to(list, height) when length(list) >= height, do: Enum.take(list, height)
  defp pad_to(list, height), do: list ++ List.duplicate("", height - length(list))
end
