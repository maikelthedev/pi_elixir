defmodule PiTui.Component.SettingsList do
  @moduledoc "Interactive settings list with edit-in-place support."

  @type setting :: {String.t(), term(), String.t()}

  @doc "Renders a list of settings with current values."
  def render(settings, selected \\ 0) do
    Enum.with_index(settings)
    |> Enum.map(fn {{name, value, type}, i} ->
      prefix = if i == selected, do: " #{PiTui.Terminal.styled(">", :cyan)} ", else: "   "
      val_str = format_value(value, type)
      "#{prefix}#{PiTui.Terminal.styled(name, :bold)} = #{val_str}"
    end)
  end

  @doc "Formats a setting value for display."
  def format_value(value, :bool) when is_boolean(value) do
    if value, do: PiTui.Terminal.styled("true", :green), else: PiTui.Terminal.styled("false", :red)
  end

  def format_value(value, :string) when is_binary(value), do: "\"#{value}\""
  def format_value(value, :number), do: inspect(value)
  def format_value(value, :enum), do: PiTui.Terminal.styled(inspect(value), :cyan)
  def format_value(value, _), do: inspect(value)
end
