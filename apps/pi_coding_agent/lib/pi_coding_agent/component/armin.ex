defmodule PiCodingAgent.Component.Armin do
  @moduledoc "ASCII art companion for the TUI."
  def render do
    [PiTui.Terminal.styled("  ╔══════════════════╗", :dim),
     PiTui.Terminal.styled("  ║  ◉  pi agent  ◉  ║", :cyan),
     PiTui.Terminal.styled("  ╚══════════════════╝", :dim), ""]
  end
end
