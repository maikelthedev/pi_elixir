defmodule PiAi.EdgeCaseTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "message struct defaults" do
    m = %Message{role: :user, content: "test"}
    assert m.is_error == false
    assert m.tool_calls == nil
  end
  test "model struct reasoning default" do
    m = %PiAi.Model{id: "x", name: "x", provider: "x", api: "x"}
    assert m.reasoning == false
  end
  test "event stream empty" do
    assert PiAi.EventStream.parse("") == []
    assert PiAi.EventStream.parse("data: [DONE]\n\n") == []
  end
  test "event stream garbage ignored" do
    assert PiAi.EventStream.parse("not sse data\n\n") == []
  end
  test "auth load nonexistent" do
    assert PiAi.Auth.load("__nonexistent_provider__") == {:ok, nil}
  end
  test "providers list non-empty" do
    assert length(PiAi.Providers.loaded_providers()) > 5
  end
  test "images generate without key" do
    assert {:error, _} = PiAi.Images.generate("openrouter", "test")
  end
end
