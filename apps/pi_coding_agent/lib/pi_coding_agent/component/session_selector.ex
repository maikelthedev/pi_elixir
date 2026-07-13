defmodule PiCodingAgent.Component.SessionSelector do
  @moduledoc "Full session selector with metadata."
  def render(sessions, selected \\ 0) do
    header = PiTui.Terminal.styled(" Sessions (↑↓ nav, Enter resume, d delete, Esc close)", :reverse)
    items = Enum.with_index(sessions) |> Enum.map(fn {s, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      id = String.slice(s["session_id"] || "?", 0, 16)
      count = length(s["messages"] || [])
      ts = String.slice(s["timestamp"] || "??", 0, 19)
      model = s["model"] || "?"
      "#{prefix} #{id}  #{count} msgs  #{model}  #{ts}"
    end)
    [header] ++ (if items == [], do: ["  #{PiTui.Terminal.styled("(no sessions)", :dim)}"], else: items)
  end
end
