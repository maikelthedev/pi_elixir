defmodule PiTui.Utils do
  @moduledoc "Shared utility functions for the TUI."

  @doc "Returns the terminal size as {rows, cols}. Cached briefly."
  def terminal_size do
    cols =
      case :io.columns() do
        {:ok, c} -> c
        _ -> 80
      end

    rows =
      case :io.rows() do
        {:ok, r} -> r
        _ -> 24
      end

    {rows, cols}
  end

  @doc "Returns column count."
  def width, do: elem(terminal_size(), 1)

  @doc "Returns row count."
  def height, do: elem(terminal_size(), 0)

  @doc "Chunks a list into groups of size n."
  def chunk(list, n), do: chunk(list, n, [])
  defp chunk([], _n, acc), do: Enum.reverse(acc)
  defp chunk(list, n, acc) do
    {head, tail} = Enum.split(list, n)
    chunk(tail, n, [head | acc])
  end

  @doc "Clamps a value between min and max."
  def clamp(val, min, max), do: max(min, min(val, max))

  @doc "Generates a unique timestamp-based ID."
  def unique_id, do: "id_#{:erlang.system_time(:microsecond)}"
end
