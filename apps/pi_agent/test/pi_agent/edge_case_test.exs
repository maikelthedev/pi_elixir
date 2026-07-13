defmodule PiAgent.EdgeCaseTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "loop process_response handles empty" do
    {:done, msgs} = PiAgent.Loop.process_response(%{}, [], %{}, :test, :openai)
    assert length(msgs) == 1
  end
  test "agent start and message roundtrip" do
    m = %PiAi.Model{id: "t", name: "t", provider: "t", api: "t"}
    {:ok, pid} = PiAgent.Agent.start_link(model: m)
    assert :ok = PiAgent.Agent.add_message(pid, %Message{role: :user, content: "hi"})
    assert length(PiAgent.Agent.get_messages(pid)) == 1
    Process.unlink(pid)
    Process.exit(pid, :kill)
  end
end
