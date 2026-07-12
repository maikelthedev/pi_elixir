defmodule PiAgent.Tool.Registry do
  @moduledoc """
  A GenServer-based registry for managing tools.

  Tools are registered by name and can be looked up at runtime
  by the agent loop when the LLM requests a tool call.
  """

  use GenServer

  @name __MODULE__

  # Client API

  @doc """
  Starts the registry with a given name.
  """
  def start_link(opts \\ []) do
    name = Keyword.get(opts, :name, @name)
    GenServer.start_link(__MODULE__, :ok, name: name)
  end

  @doc """
  Registers a tool module under the given name.
  """
  @spec register(atom(), module()) :: :ok
  def register(name, module, registry \\ @name) do
    GenServer.call(registry, {:register, name, module})
  end

  @doc """
  Looks up a tool module by name.

  Returns `{:ok, module}` or `:error`.
  """
  @spec lookup(atom()) :: {:ok, module()} | :error
  def lookup(name, registry \\ @name) do
    GenServer.call(registry, {:lookup, name})
  end

  @doc """
  Returns a list of all registered tool names.
  """
  @spec list(atom()) :: [atom()]
  def list(registry \\ @name) do
    GenServer.call(registry, :list)
  end

  # Server callbacks

  @impl true
  def init(:ok) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:register, name, module}, _from, state) do
    {:reply, :ok, Map.put(state, name, module)}
  end

  @impl true
  def handle_call({:lookup, name}, _from, state) do
    case Map.fetch(state, name) do
      {:ok, module} -> {:reply, {:ok, module}, state}
      :error -> {:reply, :error, state}
    end
  end

  @impl true
  def handle_call(:list, _from, state) do
    {:reply, Map.keys(state), state}
  end
end
