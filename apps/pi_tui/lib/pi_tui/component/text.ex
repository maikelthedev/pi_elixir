defmodule PiTui.Component.Text do
  @moduledoc "Text rendering utilities for styled terminal output."

  @doc "Renders text with word wrapping at the given width."
  def wrap(text, width) do
    text
    |> String.split("\n")
    |> Enum.flat_map(fn line ->
      if String.length(line) <= width, do: [line], else: do_wrap(line, width, [])
    end)
  end

  defp do_wrap("", _, acc), do: Enum.reverse(acc)
  defp do_wrap(text, width, acc) do
    if String.length(text) <= width do
      Enum.reverse([text | acc])
    else
      {chunk, rest} = String.split_at(text, width)
      do_wrap(rest, width, [chunk | acc])
    end
  end

  @doc "Truncates text to fit width with ellipsis."
  def truncate(text, width) when byte_size(text) <= width, do: text
  def truncate(text, width), do: String.slice(text, 0, width - 1) <> "…"
end
