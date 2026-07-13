defmodule PiCodingAgent.Component.KeybindingHints do
  @moduledoc "Keyboard shortcut hints overlay."
  def render do
    [PiTui.Terminal.styled(" Keyboard Shortcuts", :reverse),
     "",
     "  #{PiTui.Terminal.styled("Ctrl+C", :cyan)}  Exit",
     "  #{PiTui.Terminal.styled("Ctrl+P", :cyan)}  Open model selector",
     "  #{PiTui.Terminal.styled("Ctrl+T", :cyan)}  Open thinking level selector",
     "  #{PiTui.Terminal.styled("Ctrl+S", :cyan)}  Save session",
     "  #{PiTui.Terminal.styled("Ctrl+L", :cyan)}  Clear screen",
     "  #{PiTui.Terminal.styled("Tab", :cyan)}     Cycle model",
     "  #{PiTui.Terminal.styled("↑/↓", :cyan)}     History navigation",
     "  #{PiTui.Terminal.styled("←/→", :cyan)}     Cursor movement",
     "  #{PiTui.Terminal.styled("Home", :cyan)}    Line start",
     "  #{PiTui.Terminal.styled("End", :cyan)}     Line end",
     ""]
  end
end
