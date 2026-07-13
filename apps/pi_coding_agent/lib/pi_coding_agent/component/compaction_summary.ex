defmodule PiCodingAgent.Component.CompactionSummary do
  @moduledoc "Displays compaction summary message."
  def render(summary_text) do
    [PiTui.Terminal.styled(" 📋 Conversation compacted", :reverse),
     "  #{PiTui.Terminal.styled(summary_text, :dim)}",
     ""]
  end
end
