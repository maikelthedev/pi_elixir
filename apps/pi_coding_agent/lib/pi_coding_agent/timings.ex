defmodule PiCodingAgent.Timings do
  @moduledoc "Performance timing and metrics collection."
  defstruct [:timers, :metrics]

  def new, do: %__MODULE__{timers: %{}, metrics: %{}}

  def start_timer(timings, name) do
    %{timers: Map.put(timings.timers, name, System.monotonic_time()), metrics: timings.metrics}
  end

  def stop_timer(timings, name) do
    case Map.pop(timings.timers, name) do
      {nil, _} -> timings
      {start, timers} ->
        elapsed = System.monotonic_time() - start
        duration_ms = System.convert_time_unit(elapsed, :native, :millisecond)
        metrics = Map.update(timings.metrics, name, [duration_ms], &[duration_ms | &1])
        %{timings: timers, metrics: metrics}
    end
  end

  def elapsed_ms(timings, name) do
    case Map.get(timings.metrics, name) do
      nil -> 0
      [latest | _] -> latest
      [] -> 0
    end
  end

  def total_ms(timings, name) do
    case Map.get(timings.metrics, name) do
      nil -> 0
      durations -> Enum.sum(durations)
    end
  end

  def average_ms(timings, name) do
    case Map.get(timings.metrics, name) do
      nil -> 0
      durations -> div(Enum.sum(durations), length(durations))
    end
  end

  def summary(timings) do
    timings.metrics
    |> Enum.map(fn {name, durations} ->
      {name, %{count: length(durations), total_ms: Enum.sum(durations),
               avg_ms: div(Enum.sum(durations), length(durations)),
               last_ms: List.first(durations)}}
    end)
    |> Map.new()
  end

  def record(timings, name, value) do
    %{timings | metrics: Map.update(timings.metrics, name, [value], &[value | &1])}
  end
end
