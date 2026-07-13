defmodule PiTui.Keys do
  @moduledoc """
  Key code definitions and parsing for terminal input.

  Handles mapping raw escape sequences to semantic key identifiers.
  Supports function keys, arrow keys, Ctrl/Alt/Meta combinations.
  """

  @type key ::
    :up | :down | :left | :right |
    :enter | :tab | :backspace | :escape |
    :home | :end | :page_up | :page_down |
    :insert | :delete |
    {:ctrl, char()} | {:alt, char()} | {:shift, char()} |
    {:func, 1..12} |
    {:char, char()}

  @doc """
  Parses a raw byte/escape sequence into a key identifier.
  Returns {key, rest} where rest is unconsumed bytes.
  """
  @spec parse(String.t()) :: {key(), String.t()}
  def parse(<<27, rest::binary>>), do: parse_escape(rest)
  def parse(<<?\n, rest::binary>>), do: {:enter, rest}
  def parse(<<?\r, rest::binary>>), do: {:enter, rest}
  def parse(<<?\t, rest::binary>>), do: {:tab, rest}
  def parse(<<?\b, rest::binary>>), do: {:backspace, rest}
  def parse(<<127, rest::binary>>), do: {:backspace, rest}
  def parse(<<3, rest::binary>>), do: {{:ctrl, ?c}, rest}
  def parse(<<4, rest::binary>>), do: {{:ctrl, ?d}, rest}
  def parse(<<6, rest::binary>>), do: {{:ctrl, ?f}, rest}
  def parse(<<14, rest::binary>>), do: {{:ctrl, ?n}, rest}
  def parse(<<16, rest::binary>>), do: {{:ctrl, ?p}, rest}
  def parse(<<18, rest::binary>>), do: {{:ctrl, ?r}, rest}
  def parse(<<21, rest::binary>>), do: {{:ctrl, ?u}, rest}
  def parse(<<24, rest::binary>>), do: {{:ctrl, ?x}, rest}
  def parse(<<25, rest::binary>>), do: {{:ctrl, ?y}, rest}
  def parse(<<26, rest::binary>>), do: {{:ctrl, ?z}, rest}
  def parse(<<c::utf8, rest::binary>>), do: {{:char, c}, rest}
  def parse(<<>>), do: {:escape, ""}
  def parse(_), do: {:escape, ""}

  defp parse_escape(<<?[, ?A, rest::binary>>), do: {:up, rest}
  defp parse_escape(<<?[, ?B, rest::binary>>), do: {:down, rest}
  defp parse_escape(<<?[, ?C, rest::binary>>), do: {:right, rest}
  defp parse_escape(<<?[, ?D, rest::binary>>), do: {:left, rest}
  defp parse_escape(<<?[, ?H, rest::binary>>), do: {:home, rest}
  defp parse_escape(<<?[, ?F, rest::binary>>), do: {:end, rest}
  defp parse_escape(<<?[, ?5, ?~, rest::binary>>), do: {:page_up, rest}
  defp parse_escape(<<?[, ?6, ?~, rest::binary>>), do: {:page_down, rest}
  defp parse_escape(<<?[, ?2, ?~, rest::binary>>), do: {:insert, rest}
  defp parse_escape(<<?[, ?3, ?~, rest::binary>>), do: {:delete, rest}
  defp parse_escape(<<?[, ?Z, rest::binary>>), do: {{:shift, :tab}, rest}
  defp parse_escape(<<?O, ?H, rest::binary>>), do: {:home, rest}
  defp parse_escape(<<?O, ?F, rest::binary>>), do: {:end, rest}
  defp parse_escape(<<?O, c, rest::binary>>) when c in ?P..?S, do: {{:func, c - ?P + 1}, rest}
  defp parse_escape(<<?[, n::binary>>) when byte_size(n) >= 2 do
    # Function keys: ESC [ 1 1 ~ = F11, etc.
    case Integer.parse(n) do
      {num, rest} when num >= 1 and num <= 20 ->
        key = cond do
          num >= 11 and num <= 15 -> {:func, num - 10 + 10}
          num >= 17 and num <= 20 -> {:func, num - 10 + 10}
          true -> {:char, ?e}
        end
        {key, drop_tilde(rest)}
      _ -> {:escape, n}
    end
  end
  defp parse_escape(rest), do: {:escape, rest}

  defp drop_tilde(<<?~, rest::binary>>), do: rest
  defp drop_tilde(rest), do: rest

  @doc "Returns a human-readable name for a key."
  def name(:up), do: "Up"
  def name(:down), do: "Down"
  def name(:left), do: "Left"
  def name(:right), do: "Right"
  def name(:enter), do: "Enter"
  def name(:tab), do: "Tab"
  def name(:backspace), do: "Backspace"
  def name(:escape), do: "Esc"
  def name(:home), do: "Home"
  def name(:end), do: "End"
  def name(:page_up), do: "PageUp"
  def name(:page_down), do: "PageDown"
  def name(:insert), do: "Insert"
  def name(:delete), do: "Delete"
  def name({:ctrl, c}), do: "C-#{<<c>>}"
  def name({:alt, c}), do: "M-#{<<c>>}"
  def name({:shift, :tab}), do: "S-Tab"
  def name({:func, n}), do: "F#{n}"
  def name({:char, c}), do: <<c>>
end
