defmodule PiCodingAgent.Utils.ChildProcess do
  @moduledoc "Child process spawning and management helpers."
  require Logger

  def spawn(command, opts \\ []) do
    stdout = Keyword.get(opts, :stdout, :pipe)
    stderr = Keyword.get(opts, :stderr, :pipe)
    cd = Keyword.get(opts, :cd)
    env = Keyword.get(opts, :env, [])

    port_opts = [:binary, :hide]
    port_opts = if stdout == :pipe, do: [:stdout | port_opts], else: port_opts
    port_opts = if stderr == :pipe, do: [:stderr | port_opts], else: port_opts

    cmd_opts = []
    cmd_opts = if cd, do: [{:cd, cd} | cmd_opts], else: cmd_opts
    cmd_opts = if env != [], do: [{:env, env} | cmd_opts], else: cmd_opts

    Port.open({:spawn, command}, port_opts)
  end

  def read_until_close(port, timeout \\ 30_000) do
    read_loop(port, [], timeout)
  end

  defp read_loop(port, acc, timeout) do
    receive do
      {^port, {:data, data}} -> read_loop(port, [data | acc], timeout)
      {^port, :closed} -> Enum.reverse(acc) |> IO.iodata_to_binary()
    after timeout ->
      Port.close(port)
      Enum.reverse(acc) |> IO.iodata_to_binary()
    end
  end

  def signal(port, signal) do
    Port.info(port) |> then(fn
      nil -> :ok
      _ -> Port.command(port, <<signal>>)
    end)
  end
end
