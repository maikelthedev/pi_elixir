defmodule PiTui.Component.Markdown do
  @moduledoc """
  Renders markdown text to ANSI-formatted terminal output.

  Supports headings, code blocks, inline code, bold, italic,
  lists, blockquotes, and horizontal rules.
  """

  @doc """
  Renders a markdown string to a list of ANSI-formatted lines
  wrapped to the given width.
  """
  @spec render(String.t(), pos_integer()) :: [String.t()]
  def render(text, width \\ 80) do
    text
    |> String.split("\n")
    |> process_lines(width, [], :none, 0)
  end

  defp process_lines([], _width, acc, _in_block, _indent), do: Enum.reverse(acc)

  defp process_lines([line | rest], width, acc, in_block, indent) do
    trimmed = String.trim_trailing(line)

    cond do
      in_block != :none and String.starts_with?(trimmed, "```") ->
        process_lines(rest, width, acc, :none, 0)

      in_block != :none ->
        rendered = "  #{PiTui.Terminal.styled(trimmed, :dim)}"
        process_lines(rest, width, [rendered | acc], in_block, indent)

      String.starts_with?(trimmed, "```") ->
        lang = String.trim_leading(trimmed, "```")
        header = PiTui.Terminal.styled("  #{lang}  ", :reverse)
        process_lines(rest, width, [header | acc], :code, indent)

      String.starts_with?(trimmed, "# ") ->
        rendered = PiTui.Terminal.styled(trimmed, :bold) |> PiTui.Terminal.styled(:underline)
        process_lines(rest, width, ["" <> rendered | acc], in_block, indent)

      String.starts_with?(trimmed, "## ") ->
        rendered = PiTui.Terminal.styled(trimmed, :bold)
        process_lines(rest, width, ["" <> rendered | acc], in_block, indent)

      String.starts_with?(trimmed, "> ") ->
        text = String.trim_leading(trimmed, "> ")
        rendered = " #{PiTui.Terminal.styled(text, :dim)}"
        process_lines(rest, width, [rendered | acc], in_block, indent)

      String.starts_with?(trimmed, "- ") or String.starts_with?(trimmed, "* ") ->
        text = String.slice(trimmed, 2..-1//1)
        rendered = "  #{PiTui.Terminal.styled("•", :cyan)} #{text}"
        process_lines(rest, width, [rendered | acc], in_block, indent)

      String.starts_with?(trimmed, "---") or String.starts_with?(trimmed, "***") ->
        rendered = String.duplicate(PiTui.Terminal.styled("─", :dim), min(width, 40))
        process_lines(rest, width, [rendered | acc], in_block, indent)

      trimmed == "" ->
        process_lines(rest, width, ["" | acc], in_block, indent)

      true ->
        rendered = inline_format(trimmed)
        process_lines(rest, width, [rendered | acc], in_block, indent)
    end
  end

  defp inline_format(text) do
    text
    |> replace_inline(~r/\*\*(.+?)\*\*/, &PiTui.Terminal.styled(&1, :bold))
    |> replace_inline(~r/\*(.+?)\*/, &PiTui.Terminal.styled(&1, :italic))
    |> replace_inline(~r/`(.+?)`/, fn match -> PiTui.Terminal.styled(PiTui.Terminal.styled(match, :yellow), :dim) end)
    |> replace_inline(~r/~~(.+?)~~/, &PiTui.Terminal.styled(&1, :dim))
  end

  defp replace_inline(text, regex, styler) do
    Regex.replace(regex, text, fn _, match -> styler.(match) end)
  end
end
