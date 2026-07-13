defmodule PiCodingAgent.Component.DynamicBorder do
  @moduledoc "Dynamic border that changes style based on mode."
  def render(title, mode \\ :normal, width \\ 60) do
    chars = case mode do
      :error -> %{tl: "╔", tr: "╗", bl: "╚", br: "╝", h: "═", v: "║"}
      :success -> %{tl: "┌", tr: "┐", bl: "└", br: "┘", h: "─", v: "│"}
      :warning -> %{tl: "╭", tr: "╮", bl: "╰", br: "╯", h: "─", v: "│"}
      _ -> %{tl: "┌", tr: "┐", bl: "└", br: "┘", h: "─", v: "│"}
    end
    inner = width - 2
    title_str = if title != "", do: " #{title} ", else: ""
    top = chars.tl <> title_str <> String.duplicate(chars.h, inner - String.length(title_str)) <> chars.tr
    [top]
  end
end
