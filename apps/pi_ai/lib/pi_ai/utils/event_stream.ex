defmodule PiAi.Utils.EventStream do
  @moduledoc "Server-sent event stream parsing for streaming API responses."
  defstruct [:buffer, events: [], done: false]

  def new, do: %__MODULE__{buffer: ""}

  def parse_chunk(stream, chunk) do
    buffer = stream.buffer <> chunk
    {events, rest} = extract_events(buffer)
    new_events = stream.events ++ events
    %{stream | buffer: rest, events: new_events}
  end

  defp extract_events(buffer) do
    case String.split(buffer, "\n\n", parts: 2) do
      [event_block, rest] ->
        events = parse_event_block(event_block)
        {events, rest}
      [incomplete] ->
        {[], incomplete}
    end
  end

  defp parse_event_block(block) do
    block
    |> String.split("\n")
    |> Enum.reduce(%{}, fn line, acc ->
      case String.split(line, ": ", parts: 2) do
        ["data", data] -> Map.update(acc, :data, data, &(&1 <> "\n" <> data))
        ["event", event] -> Map.put(acc, :event, event)
        ["id", id] -> Map.put(acc, :id, id)
        ["retry", retry] -> Map.put(acc, :retry, retry)
        _ -> acc
      end
    end)
    |> then(fn
      %{data: data} = event -> [Map.drop(event, [:data]) |> Map.put(:data, data)]
      _ -> []
    end)
  end

  def drain(stream) do
    events = stream.events
    %{stream | events: [], done: true}
  end
end
