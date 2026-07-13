defmodule PiCodingAgent.Utils.Sleep do
  @moduledoc "Sleep utilities with cancellation support."
  def sleep(ms) when ms > 0, do: Process.sleep(ms)
  def sleep(_), do: :ok

  def sleep_with_cancel(ms, cancel_ref) do
    receive do
      {:cancel, ^cancel_ref} -> {:cancelled}
    after ms -> {:ok}
    end
  end

  defp cancel_sleep(cancel_ref), do: send(self(), {:cancel, cancel_ref})

  def interval(ms, fun) when ms > 0 do
    fun.()
    Process.sleep(ms)
    interval(ms, fun)
  end
end
