defmodule PiCodingAgent.CLITest do
  use ExUnit.Case, async: true

  describe "parse_args/1" do
    test "parses basic args" do
      args = ["-p", "hello", "--model", "claude"]
      parsed = PiCodingAgent.CLI.parse_args(args)
      assert parsed.print == "hello"
      assert parsed.model == "claude"
    end

    test "parses help flag" do
      args = ["--help"]
      assert PiCodingAgent.CLI.parse_args(args).help == true
    end
  end
end
