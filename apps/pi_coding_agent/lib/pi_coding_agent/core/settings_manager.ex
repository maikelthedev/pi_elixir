defmodule PiCodingAgent.Core.SettingsManager do
  @moduledoc "Manages user and project settings."
  use GenServer
  require Logger

  defstruct [:user_settings, :project_settings, :settings_dir]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    settings_dir = Keyword.get(opts, :settings_dir, Path.join(System.user_home(), ".pi/settings"))
    user_settings = load_settings(Path.join(settings_dir, "user.json"))
    project_settings = load_settings(Path.join(settings_dir, "project.json"))
    {:ok, %__MODULE__{user_settings: user_settings, project_settings: project_settings, settings_dir: settings_dir}}
  end

  def get(key, default \\ nil), do: GenServer.call(__MODULE__, {:get, key, default})
  def set(key, value), do: GenServer.call(__MODULE__, {:set, key, value})
  def get_all, do: GenServer.call(__MODULE__, :get_all)
  def reset(key), do: GenServer.call(__MODULE__, {:reset, key})

  def handle_call({:get, key, default}, _from, state) do
    value = Map.get(state.project_settings, key, Map.get(state.user_settings, key, default))
    {:reply, value, state}
  end

  def handle_call({:set, key, value}, _from, state) do
    settings = Map.put(state.project_settings, key, value)
    save_settings(Path.join(state.settings_dir, "project.json"), settings)
    {:reply, :ok, %{state | project_settings: settings}}
  end

  def handle_call(:get_all, _from, state) do
    merged = Map.merge(state.user_settings, state.project_settings)
    {:reply, merged, state}
  end

  def handle_call({:reset, key}, _from, state) do
    settings = Map.delete(state.project_settings, key)
    save_settings(Path.join(state.settings_dir, "project.json"), settings)
    {:reply, :ok, %{state | project_settings: settings}}
  end

  defp load_settings(path) do
    case File.read(path) do
      {:ok, content} -> JSON.decode(content) |> elem(1) || %{}
      _ -> %{}
    end
  end

  defp save_settings(path, settings) do
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, JSON.encode!(settings))
  end
end
