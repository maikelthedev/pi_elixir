defmodule PiCodingAgent.Component.CountdownTimer do
  @moduledoc "Countdown timer for timed operations."
  def render(seconds_left, label \\ "Timeout") do
    bar_width = 20
    filled = max(0, min(bar_width, round(bar_width * seconds_left / 60)))
    empty = bar_width - filled
    bar = String.duplicate("█", filled) <> String.duplicate("░", empty)
    PiTui.Terminal.styled("  #{label}: #{bar} #{seconds_left}s", :yellow)
  end
end
