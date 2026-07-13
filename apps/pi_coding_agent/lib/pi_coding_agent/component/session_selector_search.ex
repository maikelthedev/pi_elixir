defmodule PiCodingAgent.Component.SessionSelectorSearch do
  @moduledoc "Searchable session selector."
  def render(sessions, query \\ "", selected \\ 0) do
    filtered = filter_sessions(sessions, query)
    visible = Enum.take(filtered, 15)
    lines = [PiTui.Terminal.styled(" Sessions (type to search, Enter select, Esc cancel)", :reverse)]
    lines = lines ++ ["  #{PiTui.Terminal.styled("Search:", :cyan)} #{query}"]
    items = Enum.with_index(visible) |> Enum.map(fn {s, i} ->
      prefix = if i == selected, do: PiTui.Terminal.styled(" >", :cyan), else: "  "
      id = String.slice(s["session_id"] || "?", 0, 16)
      count = length(s["messages"] || [])
      ts = String.slice(s["timestamp"] || "??", 0, 19)
      "#{prefix} #{id}  #{count} msgs  #{ts}"
    end)
    if items == [], do: lines ++ ["  #{PiTui.Terminal.styled("(no matches)", :dim)}"], else: lines ++ items
  end
  defp filter_sessions(sessions, ""), do: sessions
  defp filter_sessions(sessions, q) do
    q = String.downcase(q)
    Enum.filter(sessions, fn s -> String.downcase(s["session_id"] || "") =~ q end)
  end
end
