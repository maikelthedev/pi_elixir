defmodule PiAi.UtilsNewTest do
  use ExUnit.Case, async: true

  test "AbortSignals.new creates signal" do
    signal = PiAi.Utils.AbortSignals.new()
    refute PiAi.Utils.AbortSignals.aborted?(signal)
  end

  test "AbortSignals.abort marks as aborted" do
    signal = PiAi.Utils.AbortSignals.new() |> PiAi.Utils.AbortSignals.abort()
    assert PiAi.Utils.AbortSignals.aborted?(signal)
  end

  test "AbortSignals.check returns ok for non-aborted" do
    signal = PiAi.Utils.AbortSignals.new()
    assert :ok = PiAi.Utils.AbortSignals.check(signal)
  end

  test "AbortSignals.check returns error for aborted" do
    signal = PiAi.Utils.AbortSignals.new() |> PiAi.Utils.AbortSignals.abort()
    assert {:error, :aborted} = PiAi.Utils.AbortSignals.check(signal)
  end

  test "AbortSignals.on_abort adds callback" do
    signal = PiAi.Utils.AbortSignals.new()
    signal = PiAi.Utils.AbortSignals.on_abort(signal, fn -> :ok end)
    assert length(signal.callbacks) == 1
  end

  test "DeferredTools.new creates empty" do
    dt = PiAi.Utils.DeferredTools.new()
    assert PiAi.Utils.DeferredTools.count(dt) == 0
  end

  test "DeferredTools.register and resolve" do
    dt = PiAi.Utils.DeferredTools.new()
    |> PiAi.Utils.DeferredTools.register(:test, fn -> %{name: "test"} end)
    assert {:ok, %{name: "test"}} = PiAi.Utils.DeferredTools.resolve(dt, :test)
  end

  test "DeferredTools.resolve not found" do
    dt = PiAi.Utils.DeferredTools.new()
    assert {:error, :not_found} = PiAi.Utils.DeferredTools.resolve(dt, :missing)
  end

  test "DeferredTools.list returns names" do
    dt = PiAi.Utils.DeferredTools.new()
    |> PiAi.Utils.DeferredTools.register(:a, fn -> %{} end)
    |> PiAi.Utils.DeferredTools.register(:b, fn -> %{} end)
    names = PiAi.Utils.DeferredTools.list(dt)
    assert :a in names
    assert :b in names
  end
end

defmodule PiCodingAgent.UtilsHtmlTest do
  use ExUnit.Case, async: true

  test "escape" do
    assert PiCodingAgent.Utils.Html.escape("<b>\"hi\"</b>") == "&lt;b&gt;&quot;hi&quot;&lt;/b&gt;"
  end

  test "unescape" do
    assert PiCodingAgent.Utils.Html.unescape("&lt;b&gt;") == "<b>"
  end

  test "escape/unescape roundtrip" do
    original = "Hello <world> & \"friends\""
    assert original |> PiCodingAgent.Utils.Html.escape() |> PiCodingAgent.Utils.Html.unescape() == original
  end

  test "tag creates html" do
    assert PiCodingAgent.Utils.Html.tag("p", "hello") == "<p>hello</p>"
  end

  test "tag with attrs" do
    result = PiCodingAgent.Utils.Html.tag("a", "click", href: "http://example.com")
    assert result =~ "href="
    assert result =~ "click"
  end

  test "self_closing_tag" do
    assert PiCodingAgent.Utils.Html.self_closing_tag("br") == "<br />"
  end

  test "helper functions" do
    assert PiCodingAgent.Utils.Html.link("http://x.com", "click") =~ "a"
    assert PiCodingAgent.Utils.Html.code("x") =~ "code"
    assert PiCodingAgent.Utils.Html.h1("Title") =~ "h1"
    assert PiCodingAgent.Utils.Html.h2("Title") =~ "h2"
    assert PiCodingAgent.Utils.Html.h3("Title") =~ "h3"
    assert PiCodingAgent.Utils.Html.p("text") =~ "p"
    assert PiCodingAgent.Utils.Html.div("content") =~ "div"
    assert PiCodingAgent.Utils.Html.span("text") =~ "span"
  end
end
