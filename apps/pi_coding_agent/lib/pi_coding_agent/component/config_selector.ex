defmodule PiCodingAgent.Component.ConfigSelector do
  @moduledoc "Configuration selector for changing settings inline."
  def render(config_items, selected \\ 0) do
    header = PiTui.Terminal.styled(" Configuration (↑↓ nav, Enter edit)", :reverse)
    items = Enum.with_index(config_items) |> Enum.map(fn {{key, val, default}, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      val_str = if val != default, do: PiTui.Terminal.styled(inspect(val), :green), else: inspect(val)
      "#{prefix} #{String.pad_trailing(key, 20)} #{val_str}"
    end)
    [header] ++ items
  end
end
