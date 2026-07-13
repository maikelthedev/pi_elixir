defmodule PiCodingAgent.Component.BorderedLoaderTest do
  use ExUnit.Case, async: true
  test "renders with message" do
    result = PiCodingAgent.Component.BorderedLoader.render("testing", 0)
    assert Enum.join(result) =~ "testing"
  end
  test "multiple frames" do
    r1 = PiCodingAgent.Component.BorderedLoader.render("x", 0)
    r2 = PiCodingAgent.Component.BorderedLoader.render("x", 5)
    assert r1 != r2
  end
end
