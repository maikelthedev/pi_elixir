defmodule PiCodingAgent.Mode.PrintIntegrationTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "run returns on unknown provider" do
    model = %PiAi.Model{id: "test", name: "Test", provider: "test-provider", api: "openai-responses"}
    msgs = [%Message{role: :user, content: "hello"}]
    result = PiCodingAgent.Mode.Print.run(msgs, model: model)
    assert elem(result, 0) == :ok or elem(result, 0) == :error
  end
end
