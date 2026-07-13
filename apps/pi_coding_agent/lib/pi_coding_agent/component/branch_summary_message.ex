defmodule PiCodingAgent.Component.BranchSummaryMessage do
  @moduledoc "Displays branch summary/checkpoint message."
  def render(branch_name, summary_text) do
    [PiTui.Terminal.styled(" 📂 Branch: #{branch_name}", :reverse),
     "  #{PiTui.Terminal.styled(summary_text, :dim)}",
     ""]
  end
end
