defmodule PiCodingAgent.SessionSelector do
  @moduledoc "Interactive session selector for resuming conversations."

  @spec run() :: {:ok, String.t(), [PiAi.Message.t()]} | :new
  def run do
    sessions = PiCodingAgent.Session.list()

    case sessions do
      [] -> :new
      s ->
        IO.write(:stderr, PiTui.Terminal.clear_screen())
        IO.write(:stderr, PiTui.Terminal.hide_cursor())
        IO.puts(:stderr, PiTui.Terminal.styled("  Saved sessions:", :bold))
        IO.puts(:stderr, "")

        selected = pick_session(s, 0)
        PiTui.Terminal.exit_raw!()
        IO.write(:stderr, PiTui.Terminal.show_cursor())

        case selected do
          nil -> :new
          idx ->
            sid = Enum.at(s, idx)["session_id"]
            case PiCodingAgent.Session.load(sid) do
              {:ok, msgs, _meta} -> {:ok, sid, msgs}
              {:error, _} -> :new
            end
        end
    end
  end

  defp pick_session(sessions, selected, top \\ 0, max_visible \\ 15)

  defp pick_session(sessions, selected, top, max_visible) do
    list_sessions(sessions, selected, top, max_visible)
    wait_key(sessions, selected, top, max_visible)
  end

  defp wait_key(sessions, selected, top, max_visible) do
    case IO.getn(:stdio, "", 1) do
      "\n" -> selected
      "\e[A" -> pick_session(sessions, max(0, selected - 1), max(0, min(top, selected - 1)), max_visible)
      "\e[B" -> pick_session(sessions, min(selected + 1, length(sessions) - 1), top, max_visible)
      "\x03" -> nil
      _ -> pick_session(sessions, selected, top, max_visible)
    end
  end

  defp list_sessions(sessions, selected, top, max_visible) do
    visible = Enum.slice(sessions, top, max_visible)
    Enum.each(Enum.with_index(visible, top), fn {s, i} ->
      count = length(s["messages"] || [])
      ts = String.slice(s["timestamp"] || "??", 0, 19)
      id = String.slice(s["session_id"] || "?", 0, 16)
      prefix = if i == selected, do: " #{PiTui.Terminal.styled(">", :cyan)} ", else: "   "
      line = "#{prefix}#{id}  #{count} msgs  #{ts}"
      IO.write(:stderr, "\e[#{4 + i - top};1H#{String.pad_trailing(line, 78)}\e[0K")
    end)
  end
end
