defmodule PiCodingAgent.Component.Daxnuts do
  @moduledoc "Status dots decoration."
  def render(count \\ 3) do
    dots = Enum.map(1..count, fn _ -> PiTui.Terminal.styled("●", :dim) end) |> Enum.join(" ")
    "  #{dots}"
  end
  def active(idx \\ 0) do
    dots = Enum.map(0..4, fn i ->
      if i == idx, do: PiTui.Terminal.styled("●", :green), else: PiTui.Terminal.styled("●", :dim)
    end) |> Enum.join(" ")
    "  #{dots}"
  end
end
