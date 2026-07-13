defmodule PiCodingAgent.Telegraf do
  @moduledoc "Telemetry reporter — prints session stats at exit."
  def report do
    case Process.whereis(PiCodingAgent.EventBus) do
      pid when is_pid(pid) ->
        history = PiCodingAgent.EventBus.history(50)
        model_switches = Enum.count(history, &(&1.type == :model_changed))
        tool_calls = Enum.count(history, &(&1.type == :tool_call))
        errors = Enum.count(history, &(&1.type == :error))
        session_time = session_duration(history)

        IO.puts(:stderr, "\n#{PiTui.Terminal.styled(" Session Summary ", :reverse)}")
        IO.puts(:stderr, "  Duration: #{session_time}")
        IO.puts(:stderr, "  Model switches: #{model_switches}")
        IO.puts(:stderr, "  Tool calls: #{tool_calls}")
        IO.puts(:stderr, "  Errors: #{errors}")

      nil ->
        :ok
    end
  end

  defp session_duration(history) do
    case Enum.filter(history, &(&1.type == :session_start)) do
      [start | _] ->
        elapsed = DateTime.utc_now() |> DateTime.to_unix() |> Kernel.-(start.timestamp)
        minutes = div(elapsed, 60)
        seconds = rem(elapsed, 60)
        "#{minutes}m #{seconds}s"
      _ -> "unknown"
    end
  end
end
