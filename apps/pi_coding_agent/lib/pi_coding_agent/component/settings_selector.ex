defmodule PiCodingAgent.Component.SettingsSelector do
  @moduledoc "Interactive settings selector."
  def render(settings, selected \\ 0) do
    header = PiTui.Terminal.styled(" Settings (↑↓ nav, Enter edit, Esc close)", :reverse)
    items = Enum.with_index(settings) |> Enum.map(fn {{key, val}, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      "#{prefix} #{key}: #{inspect(val)}"
    end)
    [header] ++ items
  end
end
