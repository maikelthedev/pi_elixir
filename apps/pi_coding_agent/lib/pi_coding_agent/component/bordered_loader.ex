defmodule PiCodingAgent.Component.BorderedLoader do
  @moduledoc "Full-width bordered loader with message."
  def render(msg, frame \\ 0) do
    chars = %{tl: "┌", tr: "┐", bl: "└", br: "┘", h: "─", v: "│"}
    spinner = ~w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
    s = Enum.at(spinner, rem(frame, length(spinner)))
    top = chars.tl <> String.duplicate(chars.h, 50) <> chars.tr
    middle = "#{chars.v}  #{PiTui.Terminal.styled(s, :cyan)} #{msg} #{String.duplicate(" ", max(0, 45 - String.length(msg)))} #{chars.v}"
    bottom = chars.bl <> String.duplicate(chars.h, 50) <> chars.br
    [top, middle, bottom]
  end
end
