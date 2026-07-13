defmodule PiOrchestrator.Radius do
  @moduledoc "Manages scope/radius for orchestrator sessions. Controls which files/dirs a session can access."
  defstruct [:allowed_paths, :denied_paths, :max_file_size, :allow_network]

  @type t :: %__MODULE__{
    allowed_paths: [String.t()], denied_paths: [String.t()],
    max_file_size: integer(), allow_network: boolean()
  }

  @default_max_file_size 10_000_000

  def default do
    home = System.user_home()
    %__MODULE__{
      allowed_paths: [home, "/tmp"],
      denied_paths: [Path.join(home, ".ssh"), Path.join(home, ".gnupg")],
      max_file_size: @default_max_file_size,
      allow_network: true
    }
  end

  def for_project(project_dir) do
    parent = Path.dirname(project_dir)
    %{default() | allowed_paths: [project_dir, parent, "/tmp"]}
  end

  def allows?(%__MODULE__{} = radius, path) when is_nil(path), do: true
  def allows?(%__MODULE__{} = radius, path) do
    normalized = Path.expand(path)
    denied = Enum.any?(radius.denied_paths, &String.starts_with?(normalized, &1))
    allowed = Enum.any?(radius.allowed_paths, &String.starts_with?(normalized, &1))
    not denied and allowed
  end
end
