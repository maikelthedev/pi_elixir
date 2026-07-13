defmodule PiCodingAgent.Component.SettingsSelectorTest do
  use ExUnit.Case, async: true
  test "renders settings" do
    result = PiCodingAgent.Component.SettingsSelector.render([{"theme", "dark"}], 0)
    assert Enum.join(result) =~ "theme"
  end
end
