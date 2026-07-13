defmodule PiAi.Utils.Retry do
  @moduledoc "Retry logic with exponential backoff for failed API calls."
  require Logger

  def retry(fun, opts \\ []) do
    max_retries = Keyword.get(opts, :max_retries, 3)
    base_delay = Keyword.get(opts, :base_delay, 1000)
    max_delay = Keyword.get(opts, :max_delay, 30_000)
    retryable? = Keyword.get(opts, :retryable?, &default_retryable?/1)
    do_retry(fun, max_retries, base_delay, max_delay, retryable?, 0)
  end

  defp do_retry(fun, 0, _base, _max, _retryable?, _attempt) do
    case fun.() do
      {:ok, _} = result -> result
      {:error, reason} -> {:error, reason}
      other -> {:ok, other}
    end
  end

  defp do_retry(fun, retries_remaining, base, max, retryable?, attempt) do
    case fun.() do
      {:ok, _} = result -> result
      {:error, reason} = error ->
        if retryable?.(reason) and retries_remaining > 0 do
          delay = calculate_delay(base, max, attempt)
          Logger.warning("Retry #{attempt + 1}/#{attempt + retries_remaining} after #{delay}ms: #{inspect(reason)}")
          Process.sleep(delay)
          do_retry(fun, retries_remaining - 1, base, max, retryable?, attempt + 1)
        else
          error
        end
      other -> {:ok, other}
    end
  end

  defp calculate_delay(base, max, attempt) do
    delay = base * Integer.pow(2, attempt)
    jitter = if delay > 4, do: :rand.uniform(div(delay, 4)), else: 0
    min(delay + jitter, max)
  end

  defp default_retryable?(:timeout), do: true
  defp default_retryable?(:econnrefused), do: true
  defp default_retryable?(:econnreset), do: true
  defp default_retryable?(%{retryable: true}), do: true
  defp default_retryable?(429), do: true
  defp default_retryable?(500), do: true
  defp default_retryable?(502), do: true
  defp default_retryable?(503), do: true
  defp default_retryable?(_), do: false
end
