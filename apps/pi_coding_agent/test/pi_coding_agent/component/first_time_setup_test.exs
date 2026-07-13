defmodule PiCodingAgent.Component.FirstTimeSetupTest do
  use ExUnit.Case, async: true
  test "welcome renders" do
    assert PiCodingAgent.Component.FirstTimeSetup.render_welcome() |> Enum.join() =~ "Welcome"
  end
  test "api key prompt renders" do
    assert PiCodingAgent.Component.FirstTimeSetup.render_api_key_prompt("openai") |> Enum.join() =~ "openai"
  end
  test "done renders" do
    assert PiCodingAgent.Component.FirstTimeSetup.render_done() |> Enum.join() =~ "complete"
  end
end
