defmodule PiCodingAgent.Component.UserMessageSelector do
  @moduledoc "Selector for choosing a user message from history to edit/resend."
  def render(messages, selected \\ 0) do
    header = PiTui.Terminal.styled(" User Messages (↑↓ nav, Enter edit/resend, Esc close)", :reverse)
    user_msgs = Enum.filter(messages, &(&1.role == :user))
    items = Enum.with_index(user_msgs) |> Enum.map(fn {%{content: c}, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      truncated = String.slice(c || "", 0, 60)
      "#{prefix} #{truncated}#{if String.length(c || "") > 60, do: "…", else: ""}"
    end)
    if items == [] do
      [header, "  #{PiTui.Terminal.styled("(no user messages)", :dim)}"]
    else
      [header] ++ items
    end
  end
end
