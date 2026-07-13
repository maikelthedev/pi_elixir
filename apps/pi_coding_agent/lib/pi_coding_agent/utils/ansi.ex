defmodule PiCodingAgent.Utils.Ansi do
  @moduledoc "ANSI escape code handling and processing."
  @ansi_regex ~r/\x1b\[[0-9;]*[a-zA-Z]/

  def strip(text) when is_binary(text), do: Regex.replace(@ansi_regex, text, "")

  def color(text, color) do
    code = color_code(color)
    "\e[#{code}m#{text}\e[0m"
  end

  def bold(text), do: "\e[1m#{text}\e[22m"
  def dim(text), do: "\e[2m#{text}\e[22m"
  def italic(text), do: "\e[3m#{text}\e[23m"
  def underline(text), do: "\e[4m#{text}\e[24m"

  def color?(text), do: Regex.match?(@ansi_regex, text)

  def visible_length(text), do: text |> strip() |> String.length()

  def truncate_ansi(text, max_visible) do
    {result, _} = do_truncate(text, max_visible, 0, "")
    result
  end

  defp do_truncate(<<>>, _max, _count, acc), do: {acc, ""}
  defp do_truncate(text, max, count, acc) when count >= max, do: {acc, text}
  defp do_truncate(<<?\e, rest::binary>>, max, count, acc) do
    case Regex.run(~r/\x1b\[([0-9;]*[a-zA-Z])/, "\e" <> rest) do
      [full, _] ->
        skip = byte_size(full)
        <<_::binary-size(skip), remaining::binary>> = "\e" <> rest
        do_truncate(remaining, max, count, acc <> "\e" <> full)
      _ -> do_truncate(rest, max, count, acc <> <<?\e>>)
    end
  end
  defp do_truncate(<<char::utf8, rest::binary>>, max, count, acc) do
    do_truncate(rest, max, count + 1, acc <> <<char::utf8>>)
  end

  defp color_code(:red), do: 31
  defp color_code(:green), do: 32
  defp color_code(:yellow), do: 33
  defp color_code(:blue), do: 34
  defp color_code(:magenta), do: 35
  defp color_code(:cyan), do: 36
  defp color_code(:white), do: 37
  defp color_code(:black), do: 30
  defp color_code(:bright_red), do: 91
  defp color_code(:bright_green), do: 92
  defp color_code(:bright_yellow), do: 93
  defp color_code(:bright_blue), do: 94
  defp color_code(:bright_magenta), do: 95
  defp color_code(:bright_cyan), do: 96
  defp color_code(:bright_white), do: 97
  defp color_code(n) when is_integer(n), do: n
  defp color_code(_), do: 0
end
