defmodule PiTui.Component.TruncatedText do
  @moduledoc "Text that gets truncated with ellipsis if it exceeds a maximum width."

  @doc "Truncates text to fit within max_chars, adding ellipsis if needed."
  def render(text, max_chars) do
    if String.length(text) > max_chars do
      String.slice(text, 0, max_chars - 1) <> PiTui.Terminal.styled("…", :dim)
    else
      text
    end
  end

  @doc "Truncates text to a specific number of lines."
  def render_lines(lines, max_lines) do
    lines |> Enum.take(max_lines) |> then(fn l ->
      if length(lines) > max_lines do
        l ++ [PiTui.Terminal.styled("  ... (#{length(lines) - max_lines} more lines)", :dim)]
      else
        l
      end
    end)
  end
end
