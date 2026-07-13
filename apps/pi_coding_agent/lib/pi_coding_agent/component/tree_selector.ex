defmodule PiCodingAgent.Component.TreeSelector do
  @moduledoc "Tree/session branch selector."
  def render(branches, selected \\ 0) do
    header = PiTui.Terminal.styled(" Branches (↑↓ nav, Enter switch)", :reverse)
    items = Enum.with_index(branches) |> Enum.map(fn {b, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      "#{prefix} #{b}"
    end)
    [header] ++ items
  end
end
