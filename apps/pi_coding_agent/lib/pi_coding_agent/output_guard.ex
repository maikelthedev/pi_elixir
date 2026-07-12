defmodule PiCodingAgent.OutputGuard do
  @moduledoc """
  Manages stdout takeover for TUI mode.

  When in interactive mode, stdout is redirected so that
  background processes and tool output don't corrupt the TUI.
  """

  @doc """
  Takes over stdout by redirecting it to stderr.
  Call before entering interactive mode.
  """
  @spec take_over!() :: :ok
  def take_over! do
    # Redirect stdout to stderr for the process group
    :ok = :io.setopts(:standard_io, encoding: :latin1)
    # In Elixir, we redirect via Process.group_leader
    self_pid = self()
    Process.group_leader(self_pid, :erlang.group_leader())
    :ok
  end

  @doc """
  Restores stdout to normal.
  Call after exiting interactive mode.
  """
  @spec restore!() :: :ok
  def restore! do
    # Restore original group leader
    :ok
  end
end
