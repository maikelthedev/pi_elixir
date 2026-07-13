defmodule PiCodingAgent.ExtensionTest do
  use ExUnit.Case, async: true
  test "load_all returns list" do
    assert is_list(PiCodingAgent.Extension.load_all())
  end
  test "dirs returns paths" do
    dirs = PiCodingAgent.Extension.dirs()
    assert is_list(dirs)
    assert length(dirs) > 0
  end
end
