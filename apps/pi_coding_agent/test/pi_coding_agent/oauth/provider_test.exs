defmodule PiCodingAgent.OAuth.ProviderTest do
  use ExUnit.Case, async: true
  test "config returns anthropic settings" do
    cfg = PiCodingAgent.OAuth.Provider.config("anthropic")
    assert cfg.client_id == "anthropic-pi-agent"
    assert cfg.token_url =~ "anthropic"
  end

  test "config returns github copilot settings" do
    cfg = PiCodingAgent.OAuth.Provider.config("github-copilot")
    assert cfg.client_id =~ "Iv1."
    assert cfg.device_url =~ "github.com"
  end

  test "config returns fallback for unknown" do
    cfg = PiCodingAgent.OAuth.Provider.config("unknown")
    assert cfg.device_url == nil
  end

  test "login returns error for unknown provider" do
    assert {:error, _} = PiCodingAgent.OAuth.Provider.login("unknown")
  end
end
