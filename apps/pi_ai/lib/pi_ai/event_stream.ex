defmodule PiAi.EventStream do
  @moduledoc """
  Server-Sent Events (SSE) stream parser for LLM provider responses.

  Parses SSE format (`data: ...\\n\\n` lines) into structured events.
  Supports both OpenAI-style and Anthropic-style streaming events.
  """

  @doc """
  Parses a binary SSE blob into a list of event maps.
  """
  @spec parse(binary()) :: [map()]
  def parse(binary) do
    binary
    |> String.split("\n\n")
    |> Enum.map(&parse_event/1)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Ingests a chunk, returning accumulated events and leftover bytes.
  """
  @spec ingest(String.t(), String.t()) :: {[map()], String.t()}
  def ingest(buffer, chunk) do
    combined = buffer <> chunk
    parts = String.split(combined, "\n\n")

    case List.pop_at(parts, -1) do
      {last, rest} when is_binary(last) and last != "" ->
        {Enum.map(rest, &parse_event/1) |> Enum.reject(&is_nil/1), last}

      {_last, rest} ->
        {Enum.map(rest, &parse_event/1) |> Enum.reject(&is_nil/1), ""}
    end
  end

  @doc """
  Extracts text from an Anthropic SSE event.
  """
  def extract_text_anthropic(%{"type" => "content_block_delta", "delta" => %{"text" => text}}), do: text
  def extract_text_anthropic(%{"type" => "content_block_delta", "delta" => %{"type" => "text_delta", "text" => text}}), do: text
  def extract_text_anthropic(%{"type" => "message_stop"}), do: :done
  def extract_text_anthropic(%{"type" => "message_delta", "delta" => %{"stop_reason" => _}}), do: :done
  def extract_text_anthropic(_), do: nil

  @doc """
  Extracts text from an OpenAI SSE event.
  """
  def extract_text_openai(%{"choices" => [%{"delta" => %{"content" => text}}]}), do: text
  def extract_text_openai(%{"choices" => [%{"delta" => %{}}]}), do: nil
  def extract_text_openai(%{"choices" => [%{"finish_reason" => _reason}]}), do: :done
  def extract_text_openai(%{"choices" => []}), do: :done
  def extract_text_openai(_), do: nil

  @doc """
  Extracts tool call deltas from OpenAI streaming.
  """
  def extract_tool_call_openai(%{
        "choices" => [%{"delta" => %{"tool_calls" => [tc]}}]
      }),
      do: tc

  def extract_tool_call_openai(_), do: nil

  @doc """
  Accumulates a stream of raw SSE chunks into a complete response.
  """
  @spec accumulate(Enumerable.t(), keyword()) :: map()
  def accumulate(stream, _opts \\ []) do
    initial = %{"content" => "", "tool_calls" => []}

    {result, _buffer} =
      Enum.reduce(stream, {initial, ""}, fn chunk, {acc, buffer} ->
        {events, rest} = ingest(buffer, chunk)

        new_acc =
          Enum.reduce(events, acc, fn event, a ->
            a
            |> maybe_append_text(extract_text_openai(event))
            |> maybe_append_tool(extract_tool_call_openai(event))
          end)

        {new_acc, rest}
      end)

    result
  end

  # Private: parse a single SSE event string

  defp parse_event(""), do: nil
  defp parse_event("data: [DONE]"), do: nil

  defp parse_event(event_str) do
    case String.split(event_str, "\n") do
      ["data: " <> json | _] ->
        case JSON.decode(json) do
          {:ok, parsed} -> parsed
          {:error, _} -> nil
        end

      _ ->
        nil
    end
  end

  defp maybe_append_text(acc, nil), do: acc
  defp maybe_append_text(acc, :done), do: acc
  defp maybe_append_text(acc, text) when is_binary(text),
    do: Map.update!(acc, "content", &(&1 <> text))

  defp maybe_append_tool(acc, nil), do: acc

  defp maybe_append_tool(acc, tool) do
    Map.update!(acc, "tool_calls", fn calls ->
      index = tool["index"] || 0

      case Enum.at(calls, index) do
        nil -> calls ++ [tool]
        existing -> List.replace_at(calls, index, merge_tool_deltas(existing, tool))
      end
    end)
  end

  defp merge_tool_deltas(existing, delta) do
    efunc = existing["function"] || %{}
    dfunc = delta["function"] || %{}

    updated_func =
      efunc
      |> Map.put("name", efunc["name"] || dfunc["name"])
      |> Map.put("arguments", (efunc["arguments"] || "") <> (dfunc["arguments"] || ""))

    existing
    |> Map.put("id", existing["id"] || delta["id"])
    |> Map.put("type", existing["type"] || delta["type"])
    |> Map.put("function", updated_func)
  end
end
