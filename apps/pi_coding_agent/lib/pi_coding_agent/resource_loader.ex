defmodule PiCodingAgent.ResourceLoader do
  @moduledoc """
  Loads project resources (extensions, settings, sessions) from
  both global (~/.pi/agent/) and project (.pi/) directories.
  """

  @doc """
  Returns the effective project resource directories.
  Globals are always loaded first, then project overrides.
  """
  @spec dirs(String.t()) :: %{global: String.t(), project: String.t()}
  def dirs(project_dir \\ File.cwd!()) do
    %{
      global: Path.expand("~/.pi/agent"),
      project: Path.join(project_dir, ".pi")
    }
  end

  @doc """
  Returns the model registry file path.
  """
  @spec model_registry_path(String.t()) :: String.t()
  def model_registry_path(project_dir \\ nil) do
    if project_dir do
      Path.join(project_dir, ".pi/models.json")
    else
      Path.expand("~/.pi/agent/models.json")
    end
  end

  @doc """
  Ensures the resource directories exist.
  """
  @spec ensure_dirs!(String.t()) :: :ok
  def ensure_dirs!(project_dir \\ File.cwd!()) do
    d = dirs(project_dir)
    File.mkdir_p!(d.global)
    File.mkdir_p!(d.project)
    File.mkdir_p!(Path.join(d.global, "sessions"))
    File.mkdir_p!(Path.join(d.project, "extensions"))
    :ok
  end
end
