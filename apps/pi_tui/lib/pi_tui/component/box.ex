defmodule PiTui.Component.Box do
  @moduledoc "Draws bordered boxes for grouping content."
  @chars %{tl: "┌", tr: "┐", bl: "└", br: "┘", h: "─", v: "│"}

  @doc "Wraps content lines in a box."
  def render(lines, title \\ "", width \\ 80) do
    inner = width - 2
    title_str = if title != "", do: " #{title} ", else: ""
    top = @chars.tl <> title_str <> String.duplicate(@chars.h, inner - String.length(title_str)) <> @chars.tr
    middle = Enum.map(lines, &"#{@chars.v}#{String.pad_trailing(&1, inner)}#{@chars.v}")
    bottom = @chars.bl <> String.duplicate(@chars.h, inner) <> @chars.br
    [top, middle, bottom] |> List.flatten()
  end
end
