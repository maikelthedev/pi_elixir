defmodule PiTui.Component.AutocompleteTest do
  use ExUnit.Case, async: true
  test "completions returns matching items" do
    assert PiTui.Component.Autocomplete.completions("he", ~w(hello world help)) == ["hello", "help"]
  end
  test "empty prefix returns empty" do
    assert PiTui.Component.Autocomplete.completions("", ~w(hello world)) == []
  end
  test "render produces lines" do
    result = PiTui.Component.Autocomplete.render(["a", "b"])
    assert length(result) == 2
  end
end
