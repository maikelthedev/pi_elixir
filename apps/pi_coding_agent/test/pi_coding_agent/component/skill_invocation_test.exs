defmodule PiCodingAgent.Component.SkillInvocationTest do
  use ExUnit.Case, async: true
  test "render start" do
    assert PiCodingAgent.Component.SkillInvocation.render_start("test") =~ "test"
  end
  test "render result" do
    assert PiCodingAgent.Component.SkillInvocation.render_result("test", "done") =~ "done"
  end
  test "render error" do
    assert PiCodingAgent.Component.SkillInvocation.render_error("test", "fail") =~ "fail"
  end
end
