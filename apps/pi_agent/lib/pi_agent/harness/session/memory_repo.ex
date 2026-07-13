defmodule PiAgent.Harness.Session.MemoryRepo do
  @moduledoc "In-memory session storage (volatile)."
  use Agent

  def start_link(opts \\ []) do
    Agent.start_link(fn -> %{} end, name: opts[:name] || __MODULE__)
  end

  def save(session_id, data) do
    Agent.update(__MODULE__, fn state -> Map.put(state, session_id, data) end)
  end

  def load(session_id) do
    Agent.get(__MODULE__, fn state -> Map.get(state, session_id) end)
  end

  def list do
    Agent.get(__MODULE__, &Map.keys/1)
  end
end
