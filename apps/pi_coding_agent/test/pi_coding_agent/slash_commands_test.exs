defmodule PiCodingAgent.SlashCommandsTest do
  use ExUnit.Case, async: true
  test "parses slash commands" do
    {cmd, args} = PiCodingAgent.SlashCommands.parse("/model gpt-4o")
    assert cmd == "model"
    assert args == "gpt-4o"
  end
  test "is_command? detects commands" do
    assert PiCodingAgent.SlashCommands.is_command?("/help")
    refute PiCodingAgent.SlashCommands.is_command?("hello")
  end
  test "help returns all commands" do
    help = PiCodingAgent.SlashCommands.help()
    assert help =~ "help"
    assert help =~ "clear"
  end
end
