defmodule PiCodingAgent.Component.LoginDialog do
  @moduledoc "Login/API key entry dialog."
  def render(provider, status \\ :waiting) do
    status_line = case status do
      :waiting -> PiTui.Terminal.styled("  Enter your API key for #{provider}:", :bold)
      :success -> PiTui.Terminal.styled("  ✓ API key saved for #{provider}", :green)
      :error -> PiTui.Terminal.styled("  ✗ Invalid API key for #{provider}", :red)
    end
    [PiTui.Terminal.styled(" Login: #{provider}", :reverse), "", status_line,
     "  #{PiTui.Terminal.styled("(type key and press Enter)", :dim)}", ""]
  end
end
