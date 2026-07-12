defmodule PiTui.DifferentialRendererTest do
  use ExUnit.Case, async: true

  describe "new/1" do
    test "creates a renderer with given height" do
      renderer = PiTui.DifferentialRenderer.new(24)
      assert renderer.height == 24
      assert renderer.buffer == []
    end
  end

  describe "render/2" do
    test "first render returns all lines" do
      renderer = PiTui.DifferentialRenderer.new(3)
      lines = ["line 1", "line 2", "line 3"]

      {renderer, output} = PiTui.DifferentialRenderer.render(renderer, lines)
      assert output == "\e[Hline 1\e[0K\nline 2\e[0K\nline 3\e[0K"
      assert renderer.buffer == lines
    end

    test "second render only diffs changed lines" do
      renderer = PiTui.DifferentialRenderer.new(3)
      {renderer, _first} = PiTui.DifferentialRenderer.render(renderer, ["a", "b", "c"])

      {_renderer, output} = PiTui.DifferentialRenderer.render(renderer, ["a", "B", "c"])
      # Should only update line 2 (index 1)
      assert output =~ "\e[2;1H"
      assert output =~ "B"
    end
  end
end
