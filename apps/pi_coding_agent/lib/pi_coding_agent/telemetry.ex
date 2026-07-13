defmodule PiCodingAgent.Telemetry do
  @moduledoc """
  Performance timing and telemetry for the agent.

  Tracks request durations, token usage, tool execution times,
  and session statistics. Reports to optional telemetry endpoint.
  """

  defstruct [:timings, start_time: nil, request_count: 0, total_tokens: 0]

  @type t :: %__MODULE__{
    timings: %{String.t() => [non_neg_integer()]},
    start_time: integer() | nil,
    request_count: non_neg_integer(),
    total_tokens: non_neg_integer()
  }

  @doc "Creates a new telemetry collector."
  def new, do: %__MODULE__{timings: %{}, start_time: now()}

  @doc "Records a timing measurement."
  def timing(%__MODULE__{timings: t} = telem, label, duration_ms) do
    existing = Map.get(t, label, [])
    %{telem | timings: Map.put(t, label, [duration_ms | existing])}
  end

  @doc "Records token usage."
  def record_tokens(%__MODULE__{} = telem, count) do
    %{telem | request_count: telem.request_count + 1, total_tokens: telem.total_tokens + count}
  end

  @doc "Returns the average duration for a label."
  def avg(%__MODULE__{timings: t}, label) do
    case Map.get(t, label, []) do
      [] -> 0
      vals -> div(Enum.sum(vals), length(vals))
    end
  end

  @doc "Returns a summary string."
  def report(%__MODULE__{timings: t, request_count: rc, total_tokens: tok} = _telem) do
    lines = [
      "Requests: #{rc}",
      "Total tokens: #{tok}",
      "Avg tokens/req: #{if rc > 0, do: div(tok, rc), else: 0}"
    ]

    avg_lines =
      Map.keys(t)
      |> Enum.map(fn label ->
        a = avg(%__MODULE__{timings: t}, label)
        timing_label = String.pad_trailing(label, 25)
        "  #{timing_label} #{a}ms"
      end)

    (lines ++ avg_lines) |> Enum.join("\n")
  end

  @doc "Times a function call, recording the duration."
  def timed(telem, label, fun) do
    start = now()
    result = fun.()
    duration = now() - start
    {timing(telem, label, duration), result}
  end

  @doc "Resets all collected data."
  def reset(_telem), do: new()

  defp now, do: :erlang.system_time(:millisecond)
end
