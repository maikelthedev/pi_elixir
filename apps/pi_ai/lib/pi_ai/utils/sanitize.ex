defmodule PiAi.Utils.Sanitize do
  @moduledoc "Unicode sanitization for safe string handling."
  def sanitize_unicode(text) when is_binary(text) do
    text
    |> String.normalize(:nfc)
    |> remove_control_chars()
    |> remove_bom()
  end

  def remove_control_chars(text) do
    text
    |> String.to_charlist()
    |> Enum.reject(fn c -> c < 32 and c not in [?\n, ?\r, ?\t] end)
    |> List.to_string()
  end

  def remove_bom(<<0xEF, 0xBB, 0xBF, rest::binary>>), do: rest
  def remove_bom(text), do: text

  def safe_truncate(text, max_bytes) do
    if byte_size(text) <= max_bytes, do: text, else: do_safe_truncate(text, max_bytes, "")
  end

  defp do_safe_truncate(<<>>, _max, acc), do: acc
  defp do_safe_truncate(_text, 0, acc), do: acc
  defp do_safe_truncate(<<char::utf8, rest::binary>>, max, acc) do
    char_bytes = byte_size(<<char::utf8>>)
    if char_bytes <= max do
      do_safe_truncate(rest, max - char_bytes, acc <> <<char::utf8>>)
    else
      acc
    end
  end
end
