defmodule PiCodingAgent.Component.UserMessageSelectorTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "renders user messages from list" do
    msgs = [%Message{role: :user, content: "test msg"}, %Message{role: :assistant, content: "resp"}]
    result = PiCodingAgent.Component.UserMessageSelector.render(msgs, 0)
    assert Enum.join(result) =~ "test msg"
  end
end
