defmodule PiCodingAgent.Component.SkillInvocation do
  @moduledoc "Displays skill loading/execution."
  def render_start(skill_name) do
    PiTui.Terminal.styled("  ⚡ Invoking skill: #{skill_name}", :magenta)
  end
  def render_result(skill_name, result) do
    truncated = String.slice(result || "", 0, 100)
    PiTui.Terminal.styled("  ✓ #{skill_name}: #{truncated}#{if String.length(result || "") > 100, do: "…", else: ""}", :green)
  end
  def render_error(skill_name, reason) do
    PiTui.Terminal.styled("  ✗ #{skill_name}: #{String.slice(inspect(reason), 0, 80)}", :red)
  end
end
