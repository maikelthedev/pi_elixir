defmodule PiCodingAgent.Component.OAuthSelectorTest do
  use ExUnit.Case, async: true
  test "renders provider list" do
    result = PiCodingAgent.Component.OAuthSelector.render(["test-provider"], 0)
    assert Enum.join(result) =~ "test-provider"
  end
end
