defmodule PiCodingAgent.Exec do
  @moduledoc "Command execution with timeout, output capture, and error handling."
  require Logger

  @default_timeout 30_000

  def run(command, opts \\ []) do
    timeout = Keyword.get(opts, :timeout, @default_timeout)
    cd = Keyword.get(opts, :cd)
    env = Keyword.get(opts, :env, [])

    Logger.debug("Exec: #{command}")
    start = System.monotonic_time()

    task = Task.async(fn ->
      cmd_opts = [stderr_to_stdout: true]
      cmd_opts = if cd, do: [{:cd, cd} | cmd_opts], else: cmd_opts
      cmd_opts = if env != [], do: [{:env, env} | cmd_opts], else: cmd_opts
      System.cmd("sh", ["-c", command], cmd_opts)
    end)

    case Task.yield(task, timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, {result, exit_code}} ->
        elapsed = System.monotonic_time() - start
        Logger.debug("Exec completed in #{elapsed}µs, exit: #{exit_code}")
        %{stdout: result, exit_code: exit_code, elapsed: elapsed, timed_out: false}
      nil ->
        Logger.warning("Exec timed out after #{timeout}ms: #{command}")
        %{stdout: "", exit_code: -1, elapsed: timeout * 1000, timed_out: true}
      {:exit, reason} ->
        Logger.error("Exec exit: #{inspect(reason)}: #{command}")
        %{stdout: "", exit_code: -1, elapsed: 0, timed_out: false, error: reason}
    end
  end

  def run_live(command, _opts \\ []) do
    port = Port.open({:spawn, command}, [:binary, :line, :stderr_to_stdout])
    receive_loop(port, [])
  end

  defp receive_loop(port, acc) do
    receive do
      {^port, {:data, line}} -> receive_loop(port, [line | acc])
      {^port, :closed} -> Enum.reverse(acc) |> IO.iodata_to_binary()
    after 30_000 -> Enum.reverse(acc) |> IO.iodata_to_binary()
    end
  end
end
