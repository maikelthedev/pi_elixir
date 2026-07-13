defmodule PiCodingAgent.Component.ThemeSelectorTest do
  use ExUnit.Case, async: true
  test "renders themes" do
    result = PiCodingAgent.Component.ThemeSelector.render(1)
    assert Enum.join(result) =~ "light"
  end
end
