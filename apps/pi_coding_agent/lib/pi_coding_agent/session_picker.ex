defmodule PiCodingAgent.SessionPicker do
  @moduledoc """
  Interactive session picker for resuming previous conversations.
  """

  @doc """
  Shows a list of saved sessions and lets the user pick one.
  Returns {:ok, session_id, messages} or {:cancel, reason}.
  """
  @spec pick() :: {:ok, String.t(), [PiAi.Message.t()]} | {:cancel, String.t()}
  def pick do
    sessions = PiCodingAgent.Session.list()

    case sessions do
      [] ->
        {:cancel, "No saved sessions"}

      sessions ->
        IO.puts(:stderr, "\nSaved sessions:")
        IO.puts(:stderr, "  0. Start a new session")

        sessions
        |> Enum.with_index(1)
        |> Enum.each(fn {s, i} ->
          msg_count = length(s["messages"] || [])
          timestamp = s["timestamp"] || "unknown"
          IO.puts(:stderr, "  #{i}. Session #{String.slice(s["session_id"] || "?", 0, 20)}... (#{msg_count} msgs, #{timestamp})")
        end)

        IO.write(:stderr, "\nSelect session (0 for new): ")
        input = IO.gets(:stdio) |> String.trim()

        case Integer.parse(input) do
          {0, _} ->
            {:cancel, "new"}

          {n, _} when n > 0 and n <= length(sessions) ->
            selected = Enum.at(sessions, n - 1)
            session_id = selected["session_id"]

            case PiCodingAgent.Session.load(session_id) do
              {:ok, messages, _metadata} -> {:ok, session_id, messages}
              {:error, reason} -> {:cancel, inspect(reason)}
            end

          _ ->
            {:cancel, "new"}
        end
    end
  end
end
