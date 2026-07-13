defmodule PiCodingAgent.Component.ScopedModelsSelector do
  @moduledoc "Scoped models (cycle/available) selector."
  def render(scoped_models, all_models, selected \\ 0) do
    header = PiTui.Terminal.styled(" Models (Tab cycle through scoped, Enter expand all)", :reverse)
    items = Enum.with_index(scoped_models) |> Enum.map(fn {m, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      "#{prefix} #{m.id} #{PiTui.Terminal.styled("(#{m.provider})", :dim)}"
    end)
    summary = "  #{PiTui.Terminal.styled("+ #{length(all_models) - length(scoped_models)} more available", :dim)}"
    [header] ++ items ++ [summary]
  end
end
