defmodule PiTui.Component.Autocomplete do
  @moduledoc "Simple autocomplete dropdown for input."
  @max_items 10

  @doc "Returns matching completions for the given prefix."
  def completions(prefix, _candidates) when prefix == "", do: []

  def completions(prefix, candidates) do
    p = String.downcase(prefix)
    candidates
    |> Enum.filter(&String.starts_with?(String.downcase(&1), p))
    |> Enum.take(@max_items)
  end

  @doc "Renders the autocomplete dropdown as lines."
  def render(items, selected \\ 0) do
    Enum.with_index(items)
    |> Enum.map(fn {item, i} ->
      if i == selected, do: PiTui.Terminal.styled(" #{item}", :reverse), else: " #{item}"
    end)
  end
end
