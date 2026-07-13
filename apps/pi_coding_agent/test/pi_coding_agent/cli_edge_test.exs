defmodule PiCodingAgent.CLIEdgeTest do
  use ExUnit.Case, async: true
  test "parse empty args" do
    opts = PiCodingAgent.CLI.parse_args([])
    assert opts == %{}
  end
  test "parse version flag" do
    opts = PiCodingAgent.CLI.parse_args(["--version"])
    assert opts[:version] == true
  end
  test "parse rpc flag" do
    opts = PiCodingAgent.CLI.parse_args(["--rpc"])
    assert opts[:rpc] == true
  end
  test "parse unknown flags silently" do
    opts = PiCodingAgent.CLI.parse_args(["--bogus-flag-xyz", "value"])
    assert is_map(opts)
  end
end
