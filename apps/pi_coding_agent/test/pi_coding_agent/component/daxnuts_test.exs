defmodule PiCodingAgent.Component.DaxnutsTest do
  use ExUnit.Case, async: true
  test "renders dots" do
    assert PiCodingAgent.Component.Daxnuts.render(3) =~ "●"
  end
  test "renders active" do
    assert PiCodingAgent.Component.Daxnuts.active(2) =~ "●"
  end
end
