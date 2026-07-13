defmodule PiCodingAgent.EdgeCaseTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  test "session save/load" do
    msgs = [%Message{role: :user, content: "test"}]
    sid = PiCodingAgent.Session.save(msgs)
    {:ok, loaded, _meta} = PiCodingAgent.Session.load(sid)
    assert length(loaded) == 1
    PiCodingAgent.Session.delete(sid)
  end
  test "session list empty" do
    assert is_list(PiCodingAgent.Session.list())
  end
  test "settings get default" do
    assert PiCodingAgent.Settings.get("nonexistent_key_abc", "default") == "default"
  end
  test "export handles special chars" do
    msgs = [%Message{role: :user, content: "<test> & \"quoted\""}]
    path = "/tmp/pi_export_edge.html"
    PiCodingAgent.ExportHTML.export(msgs, path)
    content = File.read!(path)
    refute content =~ "<test>"
    assert content =~ "&lt;test&gt;"
    File.rm!(path)
  end
  test "compaction not needed for few messages" do
    refute PiCodingAgent.Compaction.needed?([%Message{role: :user, content: "hi"}])
  end
  test "provider display names" do
    assert PiCodingAgent.ProviderDisplayNames.name("anthropic") == "Anthropic"
    assert PiCodingAgent.ProviderDisplayNames.name("unknown") == "unknown"
  end
  test "resolve config value" do
    assert PiCodingAgent.ResolveConfigValue.resolve("hello") == "hello"
    assert PiCodingAgent.ResolveConfigValue.resolve(nil, "default") == "default"
  end
  test "source info format" do
    si = PiCodingAgent.SourceInfo.new(:model, "gpt-4o", "config")
    assert PiCodingAgent.SourceInfo.format(si) =~ "gpt-4o"
  end
end
