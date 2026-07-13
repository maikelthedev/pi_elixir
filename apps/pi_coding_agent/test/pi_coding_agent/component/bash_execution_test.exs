defmodule PiCodingAgent.Component.BashExecutionTest do
  use ExUnit.Case, async: true
  test "render start shows command" do
    result = PiCodingAgent.Component.BashExecution.render_start("echo hi")
    joined = Enum.join(result)
    assert joined =~ "echo hi"
  end
  test "render exit shows code" do
    assert PiCodingAgent.Component.BashExecution.render_exit(0) =~ "exit 0"
    assert PiCodingAgent.Component.BashExecution.render_exit(1) =~ "exit 1"
  end
end
