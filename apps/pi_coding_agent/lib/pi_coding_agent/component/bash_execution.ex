defmodule PiCodingAgent.Component.BashExecution do
  @moduledoc "Displays bash command execution in interactive mode."
  def render_start(cmd) do
    ["", PiTui.Terminal.styled("  $ #{cmd}", :yellow), ""]
  end
  def render_output(output) do
    truncated = String.slice(output || "", 0, 1000)
    lines = String.split(truncated, "\n")
    Enum.map(lines, &"  #{PiTui.Terminal.styled(&1, :dim)}")
  end
  def render_exit(exit_code) do
    if exit_code == 0 do
      PiTui.Terminal.styled("  ── exit 0 ──", :green)
    else
      PiTui.Terminal.styled("  ── exit #{exit_code} ──", :red)
    end
  end
end
