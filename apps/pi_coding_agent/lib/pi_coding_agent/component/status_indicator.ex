defmodule PiCodingAgent.Component.StatusIndicator do
  @moduledoc "Shows agent status (streaming, thinking, idle, error) with spinner."
  @spinner ~w(⠋ ⠙ ⠹ ⠸ ⠼ ⠴ ⠦ ⠧ ⠇ ⠏)
  def idle, do: PiTui.Terminal.styled(" ●", :green)
  def streaming(frame \\ 0), do: "#{PiTui.Terminal.styled(Enum.at(@spinner, rem(frame, length(@spinner))), :cyan)} #{PiTui.Terminal.styled("streaming", :dim)}"
  def thinking(frame \\ 0), do: "#{PiTui.Terminal.styled(Enum.at(@spinner, rem(frame, length(@spinner))), :yellow)} #{PiTui.Terminal.styled("thinking", :dim)}"
  def error, do: PiTui.Terminal.styled(" ✗ error", :red)
  def done, do: PiTui.Terminal.styled(" ✓ done", :green)
end
