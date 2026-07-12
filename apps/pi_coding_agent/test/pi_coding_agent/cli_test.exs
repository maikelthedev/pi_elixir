defmodule PiCodingAgent.CLITest do
  use ExUnit.Case, async: true

  describe "parse_args/1" do
    test "parses print flag" do
      opts = PiCodingAgent.CLI.parse_args(["-p", "hello"])
      assert opts[:print] == "hello"
    end

    test "parses help flag" do
      opts = PiCodingAgent.CLI.parse_args(["--help"])
      assert opts[:help] == true
    end

    test "parses model option" do
      opts = PiCodingAgent.CLI.parse_args(["--model", "gpt-4o"])
      assert opts[:model] == "gpt-4o"
    end

    test "parses version flag" do
      opts = PiCodingAgent.CLI.parse_args(["--version"])
      assert opts[:version] == true
    end
  end
end
