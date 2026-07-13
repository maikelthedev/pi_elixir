defmodule PiOrchestrator.SessionSupervisor do
  @moduledoc """
  DynamicSupervisor for managing agent sessions.
  """
  use DynamicSupervisor
  require Logger

  def start_link(opts \\ []) do
    DynamicSupervisor.start_link(__MODULE__, :ok, Keyword.take(opts, [:name]))
  end

  @impl true
  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def start_session(id, opts \\ []) do
    spec = %{id: id, start: {PiAgent.Agent, :start_link, [[id: id, session_id: id] ++ opts]}, restart: :temporary}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end

  def stop_session(id) do
    case find_child(id) do
      {:ok, pid} -> DynamicSupervisor.terminate_child(__MODULE__, pid)
      _ -> :ok
    end
  end

  def send_message(id, message) do
    case find_child(id) do
      {:ok, pid} -> PiAgent.Agent.send_message(pid, message)
      error -> error
    end
  end

  def active_sessions do
    DynamicSupervisor.which_children(__MODULE__)
    |> Enum.map(fn {id, pid, _type, _modules} -> %{id: id, pid: pid} end)
  end

  defp find_child(id) do
    case DynamicSupervisor.which_children(__MODULE__) |> Enum.find(fn {child_id, _, _, _} -> child_id == id end) do
      {^id, pid, _, _} -> {:ok, pid}
      nil -> {:error, :not_found}
    end
  end
end
