defmodule PiTui.Component.SettingsListTest do
  use ExUnit.Case, async: true
  test "render produces lines" do
    result = PiTui.Component.SettingsList.render([{"key", "value", :string}])
    assert length(result) == 1
  end
  test "format_value handles types" do
    assert PiTui.Component.SettingsList.format_value(true, :bool) =~ "true"
    assert PiTui.Component.SettingsList.format_value("hi", :string) =~ "hi"
  end
end
