defmodule PiOrchestrator do
  @moduledoc """
  Experimental orchestrator for managing pi agent sessions.

  Provides a Supervisor tree for starting and supervising
  agent sessions, tool registries, and IPC communication.
  """

  use Supervisor

  @doc """
  Starts the orchestrator supervisor.
  """
  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {PiAgent.Tool.Registry, name: PiAgent.Tool.Registry},
      {PiOrchestrator.SessionSupervisor, []}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Starts a new agent session with the given model.
  """
  def start_session(model, opts \\ []) do
    session_name = Keyword.get(opts, :name, :"session_#{:erlang.unique_integer([:positive])}")

    child_spec = %{
      id: session_name,
      start: {PiAgent.Agent, :start_link, [[model: model, name: session_name]]},
      type: :worker,
      restart: :temporary
    }

    Supervisor.start_child(PiOrchestrator.SessionSupervisor, child_spec)
  end

  @doc """
  Returns a list of active session pids.
  """
  def list_sessions do
    PiOrchestrator.SessionSupervisor
    |> Supervisor.which_children()
    |> Enum.map(fn {id, pid, _type, _modules} -> {id, pid} end)
  end
end
