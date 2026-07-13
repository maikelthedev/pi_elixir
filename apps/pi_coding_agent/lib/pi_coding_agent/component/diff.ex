defmodule PiCodingAgent.Component.Diff do
  @moduledoc "Inline diff display for code changes."
  def render(old_text, new_text) do
    old_lines = String.split(old_text || "", "\n")
    new_lines = String.split(new_text || "", "\n")
    render_diff(old_lines, new_lines)
  end
  defp render_diff(old, new) do
    max = max(length(old), length(new))
    Enum.map(0..(max - 1), fn i ->
      old_line = Enum.at(old, i, "")
      new_line = Enum.at(new, i, "")
      cond do
        i >= length(old) -> PiTui.Terminal.styled("+ #{new_line}", :green)
        i >= length(new) -> PiTui.Terminal.styled("- #{old_line}", :red)
        old_line != new_line -> "#{PiTui.Terminal.styled("- #{old_line}", :red)}\n#{PiTui.Terminal.styled("+ #{new_line}", :green)}"
        true -> "  #{old_line}"
      end
    end)
  end
end
