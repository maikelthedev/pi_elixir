defmodule PiCodingAgent.Component.VisualTruncate do
  @moduledoc "Visual indicator for truncated content."
  def render(original_count, max_count) do
    hidden = original_count - max_count
    if hidden > 0 do
      PiTui.Terminal.styled("  ... (#{hidden} more lines, truncated)", :dim)
    else
      ""
    end
  end
end
