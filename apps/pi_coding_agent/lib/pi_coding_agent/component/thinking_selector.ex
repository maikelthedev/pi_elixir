defmodule PiCodingAgent.Component.ThinkingSelector do
  @moduledoc "Thinking level selector."
  @levels ~w(off low medium high max)
  def render(selected \\ 2) do
    items = Enum.with_index(@levels) |> Enum.map(fn {l, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      "#{prefix} #{String.pad_trailing(l, 8)} #{if i == selected, do: PiTui.Terminal.styled("(active)", :dim), else: ""}"
    end)
    [PiTui.Terminal.styled(" Thinking Level", :reverse)] ++ items
  end
  def levels, do: @levels
end
