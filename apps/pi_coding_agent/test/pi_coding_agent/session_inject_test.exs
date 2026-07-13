defmodule PiCodingAgent.SessionInjectTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "module exports run" do
    assert function_exported?(PiCodingAgent.Session, :save, 1) or function_exported?(PiCodingAgent.Session, :save, 2)
  end
end
