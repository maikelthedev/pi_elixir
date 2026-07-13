defmodule PiCodingAgent.Utils.Html do
  @moduledoc "HTML utility functions for export and rendering."
  def escape(text) when is_binary(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")
  end

  def unescape(text) when is_binary(text) do
    text
    |> String.replace("&amp;", "&")
    |> String.replace("&lt;", "<")
    |> String.replace("&gt;", ">")
    |> String.replace("&quot;", "\"")
    |> String.replace("&#39;", "'")
  end

  def tag(name, content, attrs \\ []) do
    attr_str = Enum.map_join(attrs, " ", fn {k, v} -> "#{k}=\"#{escape(to_string(v))}\"" end)
    attr_str = if attr_str == "", do: "", else: " " <> attr_str
    "<#{name}#{attr_str}>#{content}</#{name}>"
  end

  def self_closing_tag(name, attrs \\ []) do
    attr_str = Enum.map_join(attrs, " ", fn {k, v} -> "#{k}=\"#{escape(to_string(v))}\"" end)
    attr_str = if attr_str == "", do: "", else: " " <> attr_str
    "<#{name}#{attr_str} />"
  end

  def link(href, text), do: tag("a", text, href: href)
  def image(src, alt \\ ""), do: self_closing_tag("img", src: src, alt: alt)
  def code(content), do: tag("code", content)
  def pre(content), do: tag("pre", content)
  def h1(content), do: tag("h1", content)
  def h2(content), do: tag("h2", content)
  def h3(content), do: tag("h3", content)
  def p(content), do: tag("p", content)
  def div(content, attrs \\ []), do: tag("div", content, attrs)
  def span(content, attrs \\ []), do: tag("span", content, attrs)
end
