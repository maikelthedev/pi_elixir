defmodule PiCodingAgent.Component.ExtensionInput do
  @moduledoc "Input field for extension configuration values."
  def render(label, value \\ "", cursor_pos \\ 0) do
    prompt = "#{PiTui.Terminal.styled(label, :cyan)}: "
    display = prompt <> value
    [display, PiTui.Terminal.styled("  #{String.duplicate(" ", String.length(prompt) + cursor_pos)}^", :dim)]
  end
end
