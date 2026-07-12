defmodule PiTui.FuzzyTest do
  use ExUnit.Case, async: true

  describe "match?/2" do
    test "matches simple substring" do
      assert PiTui.Fuzzy.match?("hello", "hello world")
    end

    test "matches with gaps" do
      assert PiTui.Fuzzy.match?("hlo", "hello world")
    end

    test "does not match with wrong characters" do
      refute PiTui.Fuzzy.match?("xyz", "hello")
    end

    test "is case insensitive" do
      assert PiTui.Fuzzy.match?("HELLO", "hello world")
      assert PiTui.Fuzzy.match?("hello", "HELLO WORLD")
    end

    test "matches empty query" do
      assert PiTui.Fuzzy.match?("", "anything")
    end
  end

  describe "score/2" do
    test "exact match has highest score" do
      assert PiTui.Fuzzy.score("hello", "hello") == 1.0
    end

    test "matching items have positive scores" do
      assert PiTui.Fuzzy.score("hlo", "hello world") > 0
      assert PiTui.Fuzzy.score("he", "hello world") > 0
      assert PiTui.Fuzzy.score("hw", "hello world") > 0
    end

    test "non-matching items have zero score" do
      assert PiTui.Fuzzy.score("xyz", "hello") == 0.0
    end

    test "empty query scores 1.0" do
      assert PiTui.Fuzzy.score("", "anything") == 1.0
    end
  end

  describe "filter/2" do
    test "returns matching items sorted by score" do
      items = ~w(hello world help helm)
      results = PiTui.Fuzzy.filter("he", items)
      assert length(results) > 0
      assert Enum.all?(results, fn {_item, score} -> score > 0 end)
      # Best match should be first
      scores = Enum.map(results, fn {_item, s} -> s end)
      assert scores == Enum.sort(scores, :desc)
    end

    test "returns empty list for no matches" do
      assert PiTui.Fuzzy.filter("xyz", ~w(abc def)) == []
    end
  end
end
