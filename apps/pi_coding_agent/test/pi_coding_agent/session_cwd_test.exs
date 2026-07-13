defmodule PiCodingAgent.SessionCwdTest do
  use ExUnit.Case, async: true
  test "resolves cwd from options" do
    assert PiCodingAgent.SessionCwd.resolve(cwd: "/tmp") == "/tmp"
    assert PiCodingAgent.SessionCwd.resolve(project_dir: "/home") == "/home"
  end
end
