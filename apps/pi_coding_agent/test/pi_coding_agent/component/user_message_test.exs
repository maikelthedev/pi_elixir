defmodule PiCodingAgent.Component.UserMessageTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "renders user message" do
    msg = %Message{role: :user, content: "hello"}
    lines = PiCodingAgent.Component.UserMessage.render(msg)
    assert Enum.join(lines) =~ "hello"
  end
end
