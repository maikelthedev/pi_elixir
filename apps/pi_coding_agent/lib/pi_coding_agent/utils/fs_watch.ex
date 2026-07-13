defmodule PiCodingAgent.Utils.FsWatch do
  @moduledoc "Filesystem watching for config and project changes."
  use GenServer
  require Logger

  defstruct [:paths, :callbacks, :timer_ref]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    paths = Keyword.get(opts, :paths, [])
    interval = Keyword.get(opts, :interval, 1000)
    {:ok, %__MODULE__{paths: paths, callbacks: %{}, timer_ref: nil}, {:continue, {:start_watching, interval}}}
  end

  def watch(pid, path, callback) do
    GenServer.call(pid, {:watch, path, callback})
  end

  def unwatch(pid, path) do
    GenServer.call(pid, {:unwatch, path})
  end

  def handle_continue({:start_watching, interval}, state) do
    timer_ref = Process.send_after(self(), :check, interval)
    {:noreply, %{state | timer_ref: timer_ref}}
  end

  def handle_call({:watch, path, callback}, _from, state) do
    callbacks = Map.put(state.callbacks, path, callback)
    paths = if path in state.paths, do: state.paths, else: [path | state.paths]
    {:reply, :ok, %{state | callbacks: callbacks, paths: paths}}
  end

  def handle_call({:unwatch, path}, _from, state) do
    callbacks = Map.delete(state.callbacks, path)
    paths = List.delete(state.paths, path)
    {:reply, :ok, %{state | callbacks: callbacks, paths: paths}}
  end

  def handle_info(:check, state) do
    Enum.each(state.paths, fn path ->
      case File.stat(path) do
        {:ok, %File.Stat{mtime: mtime}} ->
          last = Map.get(state.callbacks, {path, :last_mtime})
          if last and mtime > last do
            Logger.debug("File changed: #{path}")
            case Map.get(state.callbacks, path) do
              nil -> :ok
              cb -> cb.(path)
            end
          end
          state = put_in(state, [Access.key!(:callbacks), {path, :last_mtime}], mtime)
        _ -> :ok
      end
    end)
    timer_ref = Process.send_after(self(), :check, 1000)
    {:noreply, %{state | timer_ref: timer_ref}}
  end
end
