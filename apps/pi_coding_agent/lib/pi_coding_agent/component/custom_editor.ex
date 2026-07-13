defmodule PiCodingAgent.Component.CustomEditor do
  @moduledoc "Custom editor for multi-line text editing."
  def render(lines, cursor_line \\ 0, cursor_col \\ 0, scroll \\ 0, height \\ 10) do
    visible = Enum.slice(lines, scroll, height)
    items = Enum.with_index(visible, scroll) |> Enum.map(fn {line, i} ->
      num = PiTui.Terminal.styled(String.pad_leading("#{i + 1}", 3), :dim)
      marker = if i == cursor_line, do: PiTui.Terminal.styled(">", :cyan), else: " "
      "#{num}#{marker} #{line}"
    end)
    [PiTui.Terminal.styled(" Editor (Esc to close)", :reverse)] ++ items
  end
end
