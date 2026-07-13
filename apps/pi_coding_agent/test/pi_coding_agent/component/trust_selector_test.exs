defmodule PiCodingAgent.Component.TrustSelectorTest do
  use ExUnit.Case, async: true
  test "renders project name" do
    result = PiCodingAgent.Component.TrustSelector.render("my-project")
    assert Enum.join(result) =~ "my-project"
  end
end
