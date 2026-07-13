defmodule PiAi.Retry do
  @moduledoc "Retry logic for failed API calls with exponential backoff."
  @max_retries 3
  @base_delay 1000

  def with_retry(fun, opts \\ []) do
    max = Keyword.get(opts, :max_retries, @max_retries)
    do_retry(fun, max, @base_delay)
  end

  defp do_retry(_fun, 0, _delay), do: {:error, :max_retries_exceeded}
  defp do_retry(fun, attempts, delay) do
    case fun.() do
      {:ok, result} -> {:ok, result}
      {:error, reason} when attempts > 1 ->
        Process.sleep(delay)
        do_retry(fun, attempts - 1, delay * 2)
      {:error, reason} ->
        {:error, reason}
    end
  end
end
