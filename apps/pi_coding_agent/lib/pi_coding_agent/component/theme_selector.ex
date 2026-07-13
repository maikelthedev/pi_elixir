defmodule PiCodingAgent.Component.ThemeSelector do
  @moduledoc "Theme selection popup."
  @themes ~w(dark light auto)
  def render(selected \\ 0) do
    header = PiTui.Terminal.styled(" Theme (↑↓ nav, Enter select)", :reverse)
    items = Enum.with_index(@themes) |> Enum.map(fn {t, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      "#{prefix} #{String.pad_trailing(t, 8)} #{if i == selected, do: PiTui.Terminal.styled("(active)", :dim), else: ""}"
    end)
    [header] ++ items
  end
end
