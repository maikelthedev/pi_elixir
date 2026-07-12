defmodule PiCodingAgent.ProjectTrust do
  @moduledoc """
  Project trust system — prompts users before allowing potentially
  dangerous operations in untrusted projects.
  """

  @trust_file ".pi/trust"

  @doc """
  Checks if a project directory is trusted.
  """
  @spec trusted?(String.t()) :: boolean()
  def trusted?(project_dir) do
    path = Path.join(project_dir, @trust_file)
    File.exists?(path)
  end

  @doc """
  Marks a project as trusted.
  """
  @spec trust!(String.t()) :: :ok
  def trust!(project_dir) do
    path = Path.join(project_dir, @trust_file)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, "trusted")
    :ok
  end

  @doc """
  Revokes trust for a project.
  """
  @spec untrust!(String.t()) :: :ok
  def untrust!(project_dir) do
    path = Path.join(project_dir, @trust_file)
    File.rm(path)
    :ok
  end

  @doc """
  Prompts the user to confirm trust for a project.
  Returns true if trusted, false if denied.
  """
  @spec prompt_trust(String.t()) :: boolean()
  def prompt_trust(project_dir) do
    project_name = Path.basename(project_dir)

    IO.puts(:stderr, "\n⚠  Project '#{project_name}' is not yet trusted.")
    IO.puts(:stderr, "  Tools like Bash, Find, and Write can modify files.")
    IO.write(:stderr, "  Trust this project? (y/N): ")

    case IO.gets(:stdio) |> String.trim() |> String.downcase() do
      "y" ->
        trust!(project_dir)
        IO.puts(:stderr, "  #{project_name} is now trusted.")
        true

      _ ->
        IO.puts(:stderr, "  Project not trusted. Some tools may be restricted.")
        false
    end
  end
end
