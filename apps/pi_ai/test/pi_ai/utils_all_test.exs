defmodule PiAi.UtilsAllTest do
  use ExUnit.Case, async: true

  test "EventStream parses SSE data" do
    stream = PiAi.Utils.EventStream.new()
    stream = PiAi.Utils.EventStream.parse_chunk(stream, "data: hello\n\n")
    assert length(stream.events) == 1
  end

  test "EventStream handles partial chunks" do
    stream = PiAi.Utils.EventStream.new()
    stream = PiAi.Utils.EventStream.parse_chunk(stream, "data: hel")
    assert stream.events == []
    stream = PiAi.Utils.EventStream.parse_chunk(stream, "lo\n\n")
    assert length(stream.events) == 1
  end

  test "EventStream drain" do
    stream = PiAi.Utils.EventStream.new()
    stream = PiAi.Utils.EventStream.parse_chunk(stream, "data: test\n\n")
    stream = PiAi.Utils.EventStream.drain(stream)
    assert stream.events == []
    assert stream.done == true
  end

  test "JsonParse safe_decode" do
    assert {:ok, _} = PiAi.Utils.JsonParse.safe_decode(~s({"key": "value"}))
    assert {:error, _} = PiAi.Utils.JsonParse.safe_decode("not json")
  end

  test "JsonParse extract_json" do
    text = "Here is JSON: {\"a\": 1} and more text"
    assert {:ok, _} = PiAi.Utils.JsonParse.extract_json(text)
  end

  test "Overflow truncate_output" do
    big = String.duplicate("x", 200_000)
    result = PiAi.Utils.Overflow.truncate_output(big, 1000)
    assert byte_size(result) < 200_000
    assert result =~ "truncated"
  end

  test "Overflow truncate_lines" do
    big = Enum.map_join(1..5000, "\n", &"line #{&1}")
    result = PiAi.Utils.Overflow.truncate_lines(big, 100)
    assert result =~ "more lines"
  end

  test "Overflow fits?" do
    assert PiAi.Utils.Overflow.fits?("short", 100)
    refute PiAi.Utils.Overflow.fits?(String.duplicate("x", 200), 100)
  end

  test "Sanitize removes control chars" do
    text = "hello\x00\x01world"
    assert PiAi.Utils.Sanitize.sanitize_unicode(text) == "helloworld"
  end

  test "Sanitize removes BOM" do
    text = <<0xEF, 0xBB, 0xBF, "hello">>
    assert PiAi.Utils.Sanitize.sanitize_unicode(text) == "hello"
  end

  test "Sanitize safe_truncate preserves utf8" do
    text = "hello"
    assert PiAi.Utils.Sanitize.safe_truncate(text, 3) == "hel"
  end

  test "ProviderEnv detect_providers" do
    result = PiAi.Utils.ProviderEnv.detect_providers()
    assert is_list(result)
  end

  test "ProviderEnv default_provider returns string" do
    assert is_binary(PiAi.Utils.ProviderEnv.default_provider())
  end
end

defmodule PiCodingAgent.UtilsAllTest do
  use ExUnit.Case, async: true

  test "Paths.home returns string" do
    assert is_binary(PiCodingAgent.Utils.Paths.home())
  end

  test "Paths.pi_dir" do
    assert PiCodingAgent.Utils.Paths.pi_dir() =~ ".pi"
  end

  test "Paths.expand_home" do
    result = PiCodingAgent.Utils.Paths.expand_home("~/test")
    assert result =~ "test"
    assert not String.starts_with?(result, "~")
  end

  test "Paths.safe_join prevents traversal" do
    assert {:error, :path_traversal} = PiCodingAgent.Utils.Paths.safe_join("/tmp", "../../etc/passwd")
  end

  test "Paths.safe_join allows normal paths" do
    assert {:ok, _} = PiCodingAgent.Utils.Paths.safe_join("/tmp", "subdir/file.txt")
  end

  test "Mime.from_extension" do
    assert PiCodingAgent.Utils.Mime.from_extension(".ex") == "text/x-elixir"
    assert PiCodingAgent.Utils.Mime.from_extension(".json") == "application/json"
    assert PiCodingAgent.Utils.Mime.from_extension(".png") == "image/png"
    assert PiCodingAgent.Utils.Mime.from_extension(".xyz") == "application/octet-stream"
  end

  test "Mime.from_path" do
    assert PiCodingAgent.Utils.Mime.from_path("file.ex") == "text/x-elixir"
  end

  test "Mime type checks" do
    assert PiCodingAgent.Utils.Mime.image?("image/png")
    assert PiCodingAgent.Utils.Mime.text?("text/plain")
    refute PiCodingAgent.Utils.Mime.text?("image/png")
    assert PiCodingAgent.Utils.Mime.binary?("application/octet-stream")
  end

  test "Shell.detect_shell returns string" do
    assert is_binary(PiCodingAgent.Utils.Shell.detect_shell())
  end

  test "Shell.shell_name returns string" do
    assert is_binary(PiCodingAgent.Utils.Shell.shell_name())
  end

  test "Shell.shell_args returns list" do
    args = PiCodingAgent.Utils.Shell.shell_args("echo hi")
    assert is_list(args)
    assert "echo hi" in args
  end

  test "Frontmatter.parse handles no frontmatter" do
    assert {:ok, %{}, "hello"} = PiCodingAgent.Utils.Frontmatter.parse("hello")
  end

  test "Frontmatter.parse handles frontmatter" do
    text = "---\ntitle: Test\n---\nHello"
    assert {:ok, %{title: "Test"}, "Hello"} = PiCodingAgent.Utils.Frontmatter.parse(text)
  end

  test "Frontmatter.parse! handles frontmatter" do
    text = "---\ncount: 42\n---\nBody"
    {meta, body} = PiCodingAgent.Utils.Frontmatter.parse!(text)
    assert meta.count == 42
    assert body == "Body"
  end

  test "Deprecation.warn does not crash" do
    assert :ok = PiCodingAgent.Utils.Deprecation.warn("old", "new")
  end

  test "VersionCheck.update_message" do
    msg = PiCodingAgent.Utils.VersionCheck.update_message("0.1.0", "0.2.0")
    assert msg =~ "Update"
    msg2 = PiCodingAgent.Utils.VersionCheck.update_message("0.2.0", "0.2.0")
    assert msg2 =~ "latest"
  end

  test "Json.safe_decode" do
    assert {:ok, _} = PiCodingAgent.Utils.Json.safe_decode(~s({"a": 1}))
    assert {:error, _} = PiCodingAgent.Utils.Json.safe_decode("invalid")
  end

  test "Json.deep_merge" do
    result = PiCodingAgent.Utils.Json.deep_merge(%{a: 1, b: %{c: 2}}, %{b: %{d: 3}})
    assert result == %{a: 1, b: %{c: 2, d: 3}}
  end

  test "Sleep.sleep does not crash" do
    PiCodingAgent.Utils.Sleep.sleep(0)
  end
end
