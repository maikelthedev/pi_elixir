defmodule PiCodingAgent.Component.TrustSelector do
  @moduledoc "Project trust confirmation dialog."
  def render(project_name) do
    [PiTui.Terminal.styled(" Project Trust", :reverse),
     "",
     "  The project '#{project_name}' is not yet trusted.",
     "  Tools like Bash, Write, and Edit can modify files.",
     "",
     "  #{PiTui.Terminal.styled("[y]", :green)} Yes, trust this project",
     "  #{PiTui.Terminal.styled("[n]", :dim)} No, keep untrusted",
     "  #{PiTui.Terminal.styled("[v]", :dim)} View project path",
     ""]
  end
end
