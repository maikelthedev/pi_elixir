defmodule PiTui.NativeModifiersTest do
  use ExUnit.Case, async: true
  test "meta_key returns platform key" do
    key = PiTui.NativeModifiers.meta_key()
    assert key == :cmd or key == :ctrl
  end
  test "platform_bindings returns a map" do
    bindings = PiTui.NativeModifiers.platform_bindings()
    assert is_map(bindings)
  end
end
