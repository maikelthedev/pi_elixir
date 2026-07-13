defmodule PiCodingAgent.Component.FirstTimeSetup do
  @moduledoc "First-time setup wizard."
  def render_welcome do
    [PiTui.Terminal.styled(" Welcome to pi — Coding Agent", :bold),
     "",
     "  This is your first time running pi.",
     "  Let's get you set up.",
     ""]
  end
  def render_api_key_prompt(provider) do
    ["", "  Enter your #{PiTui.Terminal.styled(provider, :cyan)} API key",
     "  (or press Enter to skip):",
     ""]
  end
  def render_done do
    [PiTui.Terminal.styled(" Setup complete!", :green),
     "  You can now start using pi.",
     "  Type #{PiTui.Terminal.styled("/help", :cyan)} for available commands.",
     ""]
  end
end
