defmodule PiCodingAgent.Component.ExtensionSelector do
  @moduledoc "Extension enable/disable selector."
  def render(extensions, selected \\ 0) do
    header = PiTui.Terminal.styled(" Extensions (↑↓ nav, Space toggle, Esc close)", :reverse)
    items = Enum.with_index(extensions) |> Enum.map(fn {name, enabled}, i ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      toggle = if enabled, do: PiTui.Terminal.styled("[x]", :green), else: PiTui.Terminal.styled("[ ]", :dim)
      "#{prefix} #{toggle} #{name}"
    end)
    [header] ++ items
  end
end
