defmodule PiTui.Component.MarkdownTest do
  use ExUnit.Case, async: true

  describe "render/2" do
    test "renders headings" do
      result = PiTui.Component.Markdown.render("# Hello", 80)
      assert length(result) > 0
      assert hd(result) =~ "Hello"
    end

    test "renders code blocks" do
      result = PiTui.Component.Markdown.render("```\ncode\n```", 80)
      assert length(result) > 0
    end

    test "renders list items" do
      result = PiTui.Component.Markdown.render("- item one\n- item two", 80)
      joined = Enum.join(result, "\n")
      assert joined =~ "item one"
      assert joined =~ "item two"
    end

    test "renders inline code" do
      result = PiTui.Component.Markdown.render("Use `cmd` to run", 80)
      assert hd(result) =~ "cmd"
    end

    test "renders bold text" do
      result = PiTui.Component.Markdown.render("this is **bold** text", 80)
      joined = Enum.join(result, "\n")
      assert joined =~ "bold"
    end

    test "renders blockquotes" do
      result = PiTui.Component.Markdown.render("> quoted text", 80)
      joined = Enum.join(result, "\n")
      assert joined =~ "quoted text"
    end

    test "renders horizontal rules" do
      result = PiTui.Component.Markdown.render("---", 80)
      assert length(result) == 1
    end
  end
end
