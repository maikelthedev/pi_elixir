defmodule PiAi.Utils.EstimateTest do
  use ExUnit.Case, async: true
  test "estimate_tokens on text" do
    assert PiAi.Utils.Estimate.estimate_tokens("hello world") > 0
  end
  test "estimate_messages_tokens" do
    msgs = [%{content: "hello"}, %{content: "world"}]
    assert PiAi.Utils.Estimate.estimate_messages_tokens(msgs) > 0
  end
end

defmodule PiAi.Utils.ValidationTest do
  use ExUnit.Case, async: true
  test "validate_model" do
    assert :ok = PiAi.Utils.Validation.validate_model("anthropic/claude")
    assert {:error, _} = PiAi.Utils.Validation.validate_model("invalid")
  end
  test "validate_messages" do
    assert :ok = PiAi.Utils.Validation.validate_messages([%{role: :user, content: "hi"}])
    assert {:error, _} = PiAi.Utils.Validation.validate_messages([])
  end
  test "validate_temperature" do
    assert :ok = PiAi.Utils.Validation.validate_temperature(1.0)
    assert {:error, _} = PiAi.Utils.Validation.validate_temperature(3.0)
  end
end

defmodule PiAi.Utils.HashTest do
  use ExUnit.Case, async: true
  test "sha256 produces hex string" do
    hash = PiAi.Utils.Hash.sha256("test")
    assert String.length(hash) == 64
    assert hash =~ ~r/^[0-9a-f]+$/
  end
  test "short_hash is shorter" do
    assert String.length(PiAi.Utils.Hash.short_hash("test")) == 12
  end
  test "md5 produces hex string" do
    assert String.length(PiAi.Utils.Hash.md5("test")) == 32
  end
  test "content_hash on map" do
    assert is_binary(PiAi.Utils.Hash.content_hash(%{a: 1}))
  end
end

defmodule PiAi.SessionResourcesTest do
  use ExUnit.Case, async: true
  test "new creates resources" do
    r = PiAi.SessionResources.new("s1")
    assert r.session_id == "s1"
    assert r.api_calls == 0
  end
  test "record_call accumulates" do
    r = PiAi.SessionResources.new("s1")
    |> PiAi.SessionResources.record_call("anthropic/sonnet", 100, 50)
    |> PiAi.SessionResources.record_call("anthropic/sonnet", 200, 100)
    assert r.api_calls == 2
    assert r.input_tokens == 300
    assert r.total_cost_usd > 0
  end
  test "summary returns map" do
    r = PiAi.SessionResources.new("s1") |> PiAi.SessionResources.record_call("openai/gpt-4", 1000, 500)
    s = PiAi.SessionResources.summary(r)
    assert s.total_tokens == 1500
    assert s.api_calls == 1
  end
end
