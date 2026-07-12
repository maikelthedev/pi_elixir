defmodule PiCodingAgent.ExportHTMLTest do
  use ExUnit.Case, async: true

  alias PiAi.Message

  test "export/2 creates an HTML file" do
    path = "/tmp/pi_export_test.html"
    messages = [
      %Message{role: :user, content: "hello"},
      %Message{role: :assistant, content: "hi there"}
    ]

    PiCodingAgent.ExportHTML.export(messages, path)
    assert File.exists?(path)

    content = File.read!(path)
    assert content =~ "hello"
    assert content =~ "hi there"
    assert content =~ "<!DOCTYPE html>"

    File.rm!(path)
  end

  test "escapes HTML in content" do
    path = "/tmp/pi_export_xss_test.html"
    messages = [%Message{role: :user, content: "<script>alert('xss')</script>"}]

    PiCodingAgent.ExportHTML.export(messages, path)
    content = File.read!(path)
    refute content =~ "<script>"
    assert content =~ "&lt;script&gt;"

    File.rm!(path)
  end
end
