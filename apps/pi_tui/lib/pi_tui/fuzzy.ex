defmodule PiTui.Fuzzy do
  @moduledoc """
  Fuzzy string matching for filtering and scoring items.

  Uses a simple algorithm that scores matches based on
  consecutiveness, case-insensitive matching, and word boundaries.
  """

  @doc """
  Returns true if `query` fuzzy-matches `target` (case-insensitive).
  """
  @spec match?(String.t(), String.t()) :: boolean()
  def match?("", _target), do: true

  def match?(query, target) do
    q = String.downcase(query)
    t = String.downcase(target)
    chars_in_order?(String.to_charlist(q), String.to_charlist(t))
  end

  @doc """
  Returns a score between 0 and 1 for `query` against `target`.
  """
  @spec score(String.t(), String.t()) :: float()
  def score("", _target), do: 1.0

  def score(query, target) do
    q = String.downcase(query)
    t = String.downcase(target)
    q_list = String.to_charlist(q)
    t_list = String.to_charlist(t)

    case scan_matches(q_list, t_list, 0, 0, 0, t_list) do
      {s, matched} when matched > 0 -> min(s / (matched * 1.5 + 0.15 * matched), 1.0)
      _ -> 0.0
    end
  end

  @doc """
  Filters `items` by fuzzy match, returns `{item, score}` sorted by score desc.
  """
  @spec filter(String.t(), [String.t()]) :: [{String.t(), float()}]
  def filter("", items), do: Enum.map(items, &{&1, 1.0})

  def filter(query, items) do
    items
    |> Enum.map(fn item -> {item, score(query, item)} end)
    |> Enum.filter(fn {_item, s} -> s > 0.0 end)
    |> Enum.sort_by(fn {_item, s} -> s end, :desc)
  end

  # Private

  defp chars_in_order?([], _), do: true
  defp chars_in_order?(_, []), do: false
  defp chars_in_order?([q | qs], [t | ts]) when q == t, do: chars_in_order?(qs, ts)
  defp chars_in_order?(q_list, [_ | ts]), do: chars_in_order?(q_list, ts)

  # Scan through target with original target for position lookup
  defp scan_matches([], _t_list, score, matched, _consec, _orig), do: {score, matched}
  defp scan_matches(_q_list, [], score, matched, _consec, _orig), do: {score, matched}

  defp scan_matches([q | qs] = q_list, [t | ts] = t_list, score, matched, consec, orig) do
    if q == t do
      new_consec = consec + 1
      consec_bonus = (new_consec - 1) * 0.5

      # Word boundary: where was this char in original?
      matched_pos = length(orig) - length(t_list)
      word_bonus = if matched_pos > 0 and Enum.at(orig, matched_pos - 1) in ~c" _-./", do: 0.15, else: 0.0

      new_score = score + 1.0 + consec_bonus + word_bonus
      scan_matches(qs, ts, new_score, matched + 1, new_consec, orig)
    else
      scan_matches(q_list, ts, score, matched, 0, orig)
    end
  end
end
