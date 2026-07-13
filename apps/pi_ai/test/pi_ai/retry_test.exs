defmodule PiAi.RetryTest do
  use ExUnit.Case, async: true
  test "succeeds on first try" do
    assert PiAi.Retry.with_retry(fn -> {:ok, "success"} end) == {:ok, "success"}
  end
  test "fails after max retries" do
    {:error, reason} = PiAi.Retry.with_retry(fn -> {:error, :fail} end, max_retries: 2)
    assert reason == :fail or reason == :max_retries_exceeded
  end
end
