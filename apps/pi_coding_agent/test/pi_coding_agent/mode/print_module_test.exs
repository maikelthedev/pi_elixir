defmodule PiCodingAgent.Mode.PrintModuleTest do
  use ExUnit.Case, async: true
  test "module loads" do
    assert Code.ensure_loaded?(PiCodingAgent.Mode.Print)
  end
end
