defmodule PiCodingAgent.Component.ModelSelector do
  @moduledoc "Interactive model selector popup."
  def render(models, selected \\ 0, query \\ "", max_visible \\ 15) do
    filtered = filter_models(models, query)
    visible = Enum.slice(filtered, 0, max_visible)
    lines = [PiTui.Terminal.styled(" Models (type to search, ↑↓ nav, Enter select, Esc cancel)", :reverse)]
    lines = lines ++ ["  #{PiTui.Terminal.styled("Search:", :cyan)} #{query}"]
    items = Enum.with_index(visible)
      |> Enum.map(fn {m, i} ->
        prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
        "#{prefix} #{m.id} #{PiTui.Terminal.styled("(#{m.provider})", :dim)}"
      end)
    lines ++ items
  end
  defp filter_models(models, ""), do: models
  defp filter_models(models, query) do
    q = String.downcase(query)
    Enum.filter(models, fn m -> String.downcase(m.id) =~ q or (m.name && String.downcase(m.name) =~ q) or String.downcase(m.provider) =~ q end)
  end
end
