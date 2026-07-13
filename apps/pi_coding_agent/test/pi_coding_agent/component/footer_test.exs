defmodule PiCodingAgent.Component.FooterTest do
  use ExUnit.Case, async: true
  test "renders model name" do
    assert PiCodingAgent.Component.Footer.render("gpt-4o") =~ "gpt-4o"
  end
  test "renders different statuses" do
    idle = PiCodingAgent.Component.Footer.render("m", :idle)
    stream = PiCodingAgent.Component.Footer.render("m", :streaming)
    assert idle != stream
  end
end
