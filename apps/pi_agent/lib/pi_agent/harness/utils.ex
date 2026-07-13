defmodule PiAgent.Harness.Utils do
  @moduledoc "Utility functions for the agent harness: truncation, shell output, text processing."

  def truncate(text, max_length) when is_binary(text) and byte_size(text) > max_length do
    truncated = String.slice(text, 0, max_length)
    truncated <> "\n... [truncated at #{max_length} bytes]"
  end
  def truncate(text, _), do: text

  def truncate_lines(text, max_lines) when is_binary(text) do
    lines = String.split(text, "\n")
    if length(lines) > max_lines do
      {kept, _dropped} = Enum.split(lines, max_lines)
      Enum.join(kept, "\n") <> "\n... [#{length(lines) - max_lines} more lines]"
    else
      text
    end
  end

  def shell_output(output) when is_binary(output) do
    output
    |> String.trim_trailing()
    |> truncate(50_000)
  end

  def word_wrap(text, max_width) when is_binary(text) do
    text
    |> String.split("\n")
    |> Enum.flat_map(&wrap_line(&1, max_width))
    |> Enum.join("\n")
  end

  def escape_ansi(text) when is_binary(text) do
    Regex.replace(~r/\x1b\[[0-9;]*m/, text, "")
  end

  def strip_ansi(text) when is_binary(text), do: escape_ansi(text)

  def truncate_tokens(text, max_tokens) when is_binary(text) do
    estimated_tokens = div(byte_size(text), 4)
    if estimated_tokens <= max_tokens, do: text, else: truncate(text, max_tokens * 4)
  end

  defp wrap_line(line, max_width) do
    if String.length(line) <= max_width, do: [line],
    else: do_wrap(line, max_width, [])
  end

  defp do_wrap(<<>>, _max, acc), do: Enum.reverse(acc) |> List.flatten()
  defp do_wrap(line, max_width, acc) do
    {word, rest} = split_at_width(line, max_width)
    do_wrap(rest, max_width, [word | acc])
  end

  defp split_at_width(text, max_width) do
    if String.length(text) <= max_width, do: {text, ""}, else: do_split(text, max_width, "")
  end

  defp do_split(text, 0, acc), do: {acc, text}
  defp do_split(<<>>, _n, acc), do: {acc, ""}
  defp do_split(<<c::utf8, rest::binary>>, n, acc), do: do_split(rest, n - 1, acc <> <<c::utf8>>)
end
