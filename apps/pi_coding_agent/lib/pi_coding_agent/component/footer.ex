defmodule PiCodingAgent.Component.Footer do
  @moduledoc "Complex footer with model, status, token count, and keybinding hints."
  def render(model_name, status \\ :idle, messages \\ 0, tokens \\ 0) do
    {_rows, cols} = PiTui.Terminal.size()
    status_icon = case status do
      :idle -> PiTui.Terminal.styled(" ●", :green)
      :streaming -> PiTui.Terminal.styled(" ⟳", :yellow)
      :error -> PiTui.Terminal.styled(" ✗", :red)
      _ -> ""
    end
    left = "#{PiTui.Terminal.styled(" pi ", :reverse)} #{PiTui.Terminal.styled(model_name, :cyan)}#{status_icon}"
    right = " #{PiTui.Terminal.styled("#{messages}msgs", :dim)} #{PiTui.Terminal.styled("#{tokens}tok", :dim)} #{PiTui.Terminal.styled("Ctrl+? /help", :dim)}"
    padding = cols - String.length(PiTui.Terminal.styled(left, :reset)) - String.length(right) - 2
    if padding > 0, do: left <> String.duplicate(" ", padding) <> right, else: left
  end
end
