defmodule PiTui.Component.Spacer do
  @moduledoc "Creates vertical spacing in layouts."
  @doc "Returns n blank lines."
  def lines(n \\ 1), do: List.duplicate("", n)
end
