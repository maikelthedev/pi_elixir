defmodule PiCodingAgent.Settings do
  @moduledoc """
  Global and per-project settings management.

  Settings are stored as JSON files:
    - Global: ~/.pi/agent/settings.json
    - Project: .pi/settings.json in the project root
  """

  @global_path Path.expand("~/.pi/agent/settings.json")
  @project_file ".pi/settings.json"

  @doc """
  Loads settings, merging project settings over global defaults.
  """
  @spec load(String.t() | nil) :: map()
  def load(project_dir \\ nil) do
    global = load_file(@global_path)

    project =
      if project_dir do
        load_file(Path.join(project_dir, @project_file))
      else
        %{}
      end

    Map.merge(global, project)
  end

  @doc """
  Gets a specific setting key.
  """
  @spec get(String.t(), term(), String.t() | nil) :: term()
  def get(key, default \\ nil, project_dir \\ nil) do
    load(project_dir)
    |> Map.get(key, default)
  end

  @doc """
  Sets a global setting.
  """
  @spec set(String.t(), term()) :: :ok
  def set(key, value) do
    settings = load_file(@global_path)
    updated = Map.put(settings, key, value)
    File.mkdir_p!(Path.dirname(@global_path))
    File.write!(@global_path, JSON.encode!(updated))
    :ok
  end

  @doc """
  Sets a project-local setting.
  """
  @spec set_project(String.t(), term(), String.t()) :: :ok
  def set_project(key, value, project_dir) do
    path = Path.join(project_dir, @project_file)
    settings = load_file(path)
    updated = Map.put(settings, key, value)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, JSON.encode!(updated))
    :ok
  end

  @doc """
  Returns the default model from settings.
  """
  @spec default_model(String.t() | nil) :: String.t()
  def default_model(project_dir \\ nil) do
    get("default_model", "gpt-4o", project_dir)
  end

  defp load_file(path) do
    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, map} -> map
          {:error, _} -> %{}
        end
      {:error, _} -> %{}
    end
  end
end
