defmodule PiCodingAgent.UtilsClipboardTest do
  use ExUnit.Case, async: true
  test "copy/paste module loads" do
    assert is_atom(PiCodingAgent.Utils.Clipboard)
  end
end
