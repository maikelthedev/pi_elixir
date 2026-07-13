defmodule PiCodingAgent.Utils.Paths do
  @moduledoc "Path utility functions for the coding agent."
  def home, do: System.user_home()
  def pi_dir, do: Path.join(home(), ".pi")
  def config_dir, do: Path.join(pi_dir(), "config")
  def sessions_dir, do: Path.join(pi_dir(), "sessions")
  def cache_dir, do: Path.join(pi_dir(), "cache")
  def credentials_dir, do: Path.join(pi_dir(), "credentials")
  def models_file, do: Path.join(pi_dir(), "agent/models.json")

  def ensure_dir(path) do
    File.mkdir_p!(path)
    path
  end

  def relative_path(path, from) do
    case Path.relative_to(path, from) do
      ^path -> path
      relative -> relative
    end
  end

  def expand_home("~/" <> rest), do: Path.join(home(), rest)
  def expand_home(path), do: path

  def safe_join(base, path) do
    expanded = Path.expand(path, base)
    if String.starts_with?(expanded, Path.expand(base)) do
      {:ok, expanded}
    else
      {:error, :path_traversal}
    end
  end

  def project_root do
    case File.cwd!() do
      dir -> find_git_root(dir)
    end
  end

  defp find_git_root(dir) do
    git_dir = Path.join(dir, ".git")
    case File.dir?(git_dir) do
      true -> dir
      false ->
        parent = Path.dirname(dir)
        if parent == dir, do: nil, else: find_git_root(parent)
    end
  end
end
