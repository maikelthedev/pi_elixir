defmodule PiAgent.Harness.MessagesTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  alias PiAgent.Harness.Messages

  test "format_messages converts messages" do
    msgs = [%Message{role: :user, content: "hi"}]
    formatted = Messages.format_messages(msgs)
    assert [%{"role" => "user", "content" => "hi"}] = formatted
  end

  test "format_message includes tool fields" do
    msg = %Message{role: :assistant, content: "call", tool_calls: [%{id: "c1"}]}
    formatted = Messages.format_message(msg)
    assert formatted["role"] == "assistant"
  end

  test "compact_messages limits to max tokens" do
    msgs = for i <- 1..100, do: %Message{role: :user, content: String.duplicate("x", 1000)}
    compacted = Messages.compact_messages(msgs, 500)
    assert length(compacted) < 100
  end

  test "last_assistant_message returns correct message" do
    msgs = [
      %Message{role: :user, content: "a"},
      %Message{role: :assistant, content: "b"},
      %Message{role: :user, content: "c"},
      %Message{role: :assistant, content: "d"}
    ]
    assert %Message{content: "d"} = Messages.last_assistant_message(msgs)
  end

  test "user_messages and assistant_messages filter correctly" do
    msgs = [
      %Message{role: :user, content: "a"},
      %Message{role: :assistant, content: "b"},
      %Message{role: :user, content: "c"}
    ]
    assert length(Messages.user_messages(msgs)) == 2
    assert length(Messages.assistant_messages(msgs)) == 1
  end
end

defmodule PiAgent.Harness.UtilsTest do
  use ExUnit.Case, async: true
  alias PiAgent.Harness.Utils

  test "truncate short text unchanged" do
    assert Utils.truncate("hi", 100) == "hi"
  end

  test "truncate long text is cut" do
    result = Utils.truncate(String.duplicate("x", 200), 100)
    assert String.length(result) < 200
    assert result =~ "truncated"
  end

  test "truncate_lines" do
    text = (1..50) |> Enum.map(&"line #{&1}") |> Enum.join("\n")
    result = Utils.truncate_lines(text, 10)
    assert result =~ "more lines"
  end

  test "escape_ansi removes color codes" do
    text = "\e[31mred\e[0m"
    assert Utils.escape_ansi(text) == "red"
  end

  test "word_wrap wraps long lines" do
    result = Utils.word_wrap(String.duplicate("a", 100), 50)
    lines = String.split(result, "\n")
    assert length(lines) > 1
  end

  test "shell_output trims trailing whitespace" do
    assert Utils.shell_output("hello\n\n\n") == "hello"
  end
end

defmodule PiAgent.Harness.SessionTest do
  use ExUnit.Case, async: true
  alias PiAi.Message
  alias PiAgent.Harness.Session

  test "new creates session with defaults" do
    s = Session.new("s1")
    assert s.id == "s1"
    assert s.messages == []
  end

  test "add_message appends" do
    s = Session.new("s1") |> Session.add_message(%Message{role: :user, content: "hi"})
    assert length(s.messages) == 1
  end

  test "clear empties messages" do
    s = Session.new("s1") |> Session.add_message(%Message{role: :user, content: "hi"}) |> Session.clear()
    assert s.messages == []
  end

  test "message_count" do
    s = Session.new("s1") |> Session.add_message(%Message{role: :user, content: "a"})
    assert Session.message_count(s) == 1
  end

  test "to_map and from_map roundtrip" do
    s = Session.new("s1", [%Message{role: :user, content: "hi"}])
    m = Session.to_map(s)
    s2 = Session.from_map(m)
    assert s2.id == "s1"
    assert length(s2.messages) == 1
  end
end
