defmodule PiTui.WordNavigation do
  @moduledoc """
  Word-level cursor navigation for text editing.

  Supports forward/backward word movement and word deletion.
  """

  @word_chars ~c"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"

  @doc "Moves cursor to the beginning of the current or previous word."
  def backward(text, cursor) do
    pos = cursor - 2
    cond do
      cursor <= 0 -> 0
      pos < 0 -> 0
      true -> find_word_start(text, pos)
    end
  end

  @doc "Moves cursor to the end of the current or next word."
  def forward(text, cursor) do
    len = String.length(text)
    cond do
      cursor >= len -> len
      true -> find_word_end(text, cursor)
    end
  end

  @doc "Deletes from cursor back to the start of the word."
  def delete_backward_word(text, cursor) do
    start = backward(text, cursor)
    {String.slice(text, 0, start) <> String.slice(text, cursor..-1//1), start}
  end

  @doc "Deletes from cursor to the end of the word."
  def delete_forward_word(text, cursor) do
    e = forward(text, cursor)
    {String.slice(text, 0, cursor) <> String.slice(text, e..-1//1), cursor}
  end

  defp find_word_start(_text, pos) when pos < 0, do: 0

  defp find_word_start(text, pos) do
    char = String.at(text, pos)
    prev = if pos > 0, do: String.at(text, pos - 1), else: " "

    cond do
      char != nil and not in_word?(char) and pos > 0 and in_word?(prev) -> pos
      char != nil and not in_word?(char) -> find_word_start(text, pos - 1)
      char != nil and in_word?(char) and pos > 0 and not in_word?(prev) -> pos
      char != nil and in_word?(char) and pos > 0 -> find_word_start(text, pos - 1)
      true -> 0
    end
  end

  defp find_word_end(text, cursor) do
    len = String.length(text)
    do_find_word_end(text, cursor, len)
  end

  defp do_find_word_end(_text, pos, len) when pos >= len, do: len

  defp do_find_word_end(text, pos, len) do
    char = String.at(text, pos)
    if char != nil and in_word?(char) do
      do_find_word_end(text, pos + 1, len)
    else
      pos
    end
  end

  defp in_word?(c), do: c in @word_chars
end
