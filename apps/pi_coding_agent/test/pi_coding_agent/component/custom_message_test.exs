defmodule PiCodingAgent.Component.CustomMessageTest do
  use ExUnit.Case, async: true
  test "renders info message" do
    result = PiCodingAgent.Component.CustomMessage.render(:info, "Test Title", ["body line"])
    assert Enum.join(result) =~ "Test Title"
  end
  test "renders error message" do
    result = PiCodingAgent.Component.CustomMessage.render(:error, "Error", ["details"])
    assert Enum.join(result) =~ "Error"
  end
end
