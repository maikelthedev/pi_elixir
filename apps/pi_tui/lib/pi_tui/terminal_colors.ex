defmodule PiTui.TerminalColors do
  @moduledoc "Terminal color support and theme management."

  @doc "Returns ANSI 256-color foreground code."
  def fg(code) when code in 0..255, do: "\e[38;5;#{code}m"

  @doc "Returns ANSI 256-color background code."
  def bg(code) when code in 0..255, do: "\e[48;5;#{code}m"

  @doc "Returns ANSI true-color (24-bit) foreground code."
  def rgb_fg(r, g, b), do: "\e[38;2;#{r};#{g};#{b}m"

  @doc "Returns ANSI true-color (24-bit) background code."
  def rgb_bg(r, g, b), do: "\e[48;2;#{r};#{g};#{b}m"

  @doc "Common color palette for syntax highlighting."
  def palette do
    %{
      keyword: "\e[38;5;99m",
      string: "\e[38;5;113m",
      number: "\e[38;5;215m",
      comment: "\e[38;5;244m",
      type: "\e[38;5;81m",
      function: "\e[38;5;221m",
      variable: "\e[38;5;187m",
      operator: "\e[38;5;231m",
      error: "\e[38;5;196m",
      link: "\e[38;5;39m\e[4m",
    }
  end
end
