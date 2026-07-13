defmodule PiAi.Provider.ErrorsTest do
  use ExUnit.Case, async: true
  test "parses anthropic rate limit" do
    e = PiAi.Provider.Errors.parse("anthropic", 429, %{"error" => %{"type" => "rate_limit_error", "message" => "Too many requests"}})
    assert e.retryable == true
    assert e.code == "rate_limit_error"
  end
  test "parses openai auth error" do
    e = PiAi.Provider.Errors.parse("openai", 401, %{"error" => %{"type" => "invalid_api_key", "message" => "Incorrect API key"}})
    assert e.recoverable == true
    assert e.code == "invalid_api_key"
  end
  test "format produces string" do
    e = PiAi.Provider.Errors.parse("test", 500, %{})
    assert PiAi.Provider.Errors.format(e) =~ "500"
  end
end
