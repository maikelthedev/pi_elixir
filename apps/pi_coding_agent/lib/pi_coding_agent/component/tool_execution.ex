defmodule PiCodingAgent.Component.ToolExecution do
  @moduledoc "Displays tool execution progress and results."
  def render_start(tool_name, args \\ %{}) do
    arg_str = args |> Map.take(~w[path pattern command]) |> Enum.map(fn {k, v} -> "#{k}: #{String.slice(v || "", 0, 40)}" end) |> Enum.join(", ")
    PiTui.Terminal.styled("  ⚙ #{tool_name}(#{arg_str})", :yellow)
  end
  def render_result(tool_name, result) when is_binary(result) do
    truncated = String.slice(result, 0, 200)
    PiTui.Terminal.styled("  ✓ #{tool_name}: #{truncated}#{if String.length(result) > 200, do: "…", else: ""}", :green)
  end
  def render_result(tool_name, error) do
    PiTui.Terminal.styled("  ✗ #{tool_name}: #{String.slice(inspect(error), 0, 100)}", :red)
  end
end
