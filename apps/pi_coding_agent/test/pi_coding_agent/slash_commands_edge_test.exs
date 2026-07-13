defmodule PiCodingAgent.SlashCommandsEdgeTest do
  use ExUnit.Case, async: true
  test "parse handles empty args" do
    {cmd, args} = PiCodingAgent.SlashCommands.parse("/help")
    assert cmd == "help"
    assert args == ""
  end
  test "parse handles multi-word args" do
    {cmd, args} = PiCodingAgent.SlashCommands.parse("/model gpt-4o turbo")
    assert cmd == "model"
    assert args == "gpt-4o turbo"
  end
  test "registry contains all commands" do
    reg = PiCodingAgent.SlashCommands.registry()
    assert is_map(reg)
    assert Map.has_key?(reg, "help")
    assert Map.has_key?(reg, "exit")
  end
end
