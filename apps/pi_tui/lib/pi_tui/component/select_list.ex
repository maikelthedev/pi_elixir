defmodule PiTui.Component.SelectList do
  @moduledoc """
  Interactive select list component for choosing from options.

  Renders a scrollable list with highlighted selection cursor.
  """

  @doc """
  Renders a select list.

  Returns the ANSI output string for the list display.
  """
  @spec render([String.t()], pos_integer(), pos_integer(), pos_integer()) :: String.t()
  def render(items, selected \\ 0, top \\ 0, max_visible \\ 10) do
    visible = Enum.slice(items, top, max_visible)

    visible
    |> Enum.with_index(top)
    |> Enum.map(fn {item, idx} ->
      if idx == selected do
        PiTui.Terminal.styled("  #{item}", :reverse)
      else
        "  #{item}"
      end
    end)
    |> Enum.join("\n")
  end

  @doc """
  Renders a searchable model selector.
  """
  @spec model_selector([PiAi.Model.t()], String.t(), pos_integer(), pos_integer()) :: String.t()
  def model_selector(models, query \\ "", selected \\ 0, max_visible \\ 15) do
    filtered = filter_models(models, query)

    header = PiTui.Terminal.styled("  Models (type to search, ↑↓ navigate, Enter select, Esc cancel)", :dim)
    search_line = "  #{PiTui.Terminal.styled("Search:", :cyan)} #{query}"

    list = render(Enum.map(filtered, &"#{&1.id}  (#{&1.provider})"), selected, 0, max_visible)

    case filtered do
      [] -> "#{header}\n#{search_line}\n  #{PiTui.Terminal.styled("(no matches)", :dim)}"
      _ -> "#{header}\n#{search_line}\n#{list}"
    end
  end

  defp filter_models(models, ""), do: models

  defp filter_models(models, query) do
    q = String.downcase(query)
    Enum.filter(models, fn m ->
      String.downcase(m.id) =~ q or
        (m.name && String.downcase(m.name) =~ q) or
        String.downcase(m.provider) =~ q
    end)
  end
end
