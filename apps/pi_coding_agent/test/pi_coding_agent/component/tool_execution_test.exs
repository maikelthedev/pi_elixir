defmodule PiCodingAgent.Component.ToolExecutionTest do
  use ExUnit.Case, async: true
  test "render start shows tool name" do
    assert PiCodingAgent.Component.ToolExecution.render_start("bash", %{command: "echo hi"}) =~ "bash"
  end
  test "render result truncates long output" do
    long = String.duplicate("x", 300)
    result = PiCodingAgent.Component.ToolExecution.render_result("test", long)
    assert String.length(result) < 250
  end
end
