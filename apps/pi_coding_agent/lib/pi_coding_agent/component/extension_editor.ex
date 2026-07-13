defmodule PiCodingAgent.Component.ExtensionEditor do
  @moduledoc "Editor for editing extension source code."
  def render(code_lines, cursor_line \\ 0, scroll \\ 0, height \\ 15) do
    visible = Enum.slice(code_lines, scroll, height)
    header = PiTui.Terminal.styled(" Extension Editor (Ctrl+S save, Esc cancel)", :reverse)
    items = Enum.with_index(visible, scroll) |> Enum.map(fn {line, i} ->
      num = PiTui.Terminal.styled(String.pad_leading("#{i + 1}", 3), :dim)
      marker = if i == cursor_line, do: PiTui.Terminal.styled(">", :cyan), else: " "
      "#{num}#{marker} #{line}"
    end)
    [header] ++ items ++ [PiTui.Terminal.styled(" Ln #{cursor_line + 1}", :dim)]
  end
end
