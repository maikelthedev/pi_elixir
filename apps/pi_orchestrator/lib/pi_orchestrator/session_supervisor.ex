defmodule PiOrchestrator.SessionSupervisor do
  @moduledoc """
  DynamicSupervisor for managing agent sessions.

  Each agent session is a PiAgent.Agent GenServer started
  and supervised independently.
  """

  use DynamicSupervisor

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, Keyword.take(opts, [:name]))
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
