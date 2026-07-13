defmodule PiAi.Utils.Diagnostics do
  @moduledoc "Diagnostic utilities for debugging API calls and provider issues."
  require Logger

  def log_request(provider, model, messages, opts \\ []) do
    msg_count = length(messages)
    tools = Keyword.get(opts, :tools, [])
    tool_count = if tools, do: length(tools), else: 0
    Logger.debug("API request: #{provider}/#{model} (#{msg_count} messages, #{tool_count} tools)")
  end

  def log_response(provider, model, response, duration_ms) do
    case response do
      {:ok, resp} ->
        tokens = Map.get(resp, :usage, %{})
        input = Map.get(tokens, :input_tokens, 0)
        output = Map.get(tokens, :output_tokens, 0)
        Logger.debug("API response: #{provider}/#{model} (#{duration_ms}ms, #{input}+#{output} tokens)")
      {:error, reason} ->
        Logger.warning("API error: #{provider}/#{model} (#{duration_ms}ms): #{inspect(reason)}")
    end
  end

  def log_streaming_start(provider, model) do
    Logger.debug("Streaming start: #{provider}/#{model}")
  end

  def log_streaming_chunk(provider, model, chunk) do
    Logger.debug("Stream chunk: #{provider}/#{model} (#{byte_size(inspect(chunk))} bytes)")
  end

  def log_streaming_end(provider, model, duration_ms) do
    Logger.debug("Stream end: #{provider}/#{model} (#{duration_ms}ms)")
  end

  def log_error(provider, model, error, context \\ "") do
    Logger.error("Error #{context}: #{provider}/#{model}: #{inspect(error)}")
  end

  def timing(fun) do
    start = System.monotonic_time()
    result = fun.()
    elapsed = System.convert_time_unit(System.monotonic_time() - start, :native, :millisecond)
    {result, elapsed}
  end

  def collect_stats do
    %{
      memory: :erlang.memory(),
      processes: :erlang.system_info(:process_count),
      ets: :erlang.system_info(:ets_count),
      uptime: :erlang.statistics(:wall_clock) |> elem(0)
    }
  end
end
