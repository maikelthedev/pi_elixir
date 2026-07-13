defmodule PiCodingAgent.Component.CustomMessage do
  @moduledoc "Renders a custom message from an extension."
  def render(type, title, body_lines) do
    icon = case type do
      :info -> PiTui.Terminal.styled(" ℹ", :cyan)
      :warning -> PiTui.Terminal.styled(" ⚠", :yellow)
      :error -> PiTui.Terminal.styled(" ✗", :red)
      :success -> PiTui.Terminal.styled(" ✓", :green)
      _ -> " •"
    end
    [PiTui.Terminal.styled("#{icon} #{title}", :bold)] ++ Enum.map(body_lines, &"  #{&1}") ++ [""]
  end
end
