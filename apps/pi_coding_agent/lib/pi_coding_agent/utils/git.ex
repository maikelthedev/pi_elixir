defmodule PiCodingAgent.Utils.Git do
  @moduledoc "Git utility functions for the coding agent."
  require Logger

  def git_dir?(path) do
    System.cmd("git", ["-C", path, "rev-parse", "--git-dir"]) |> elem(1) == 0
  end

  def root_dir(path) do
    case System.cmd("git", ["-C", path, "rev-parse", "--show-toplevel"]) do
      {result, 0} -> {:ok, String.trim(result)}
      {_, _} -> {:error, :not_a_git_repo}
    end
  end

  def status(path) do
    case System.cmd("git", ["-C", path, "status", "--porcelain"]) do
      {result, 0} -> {:ok, parse_status(result)}
      error -> error
    end
  end

  def branch(path) do
    case System.cmd("git", ["-C", path, "branch", "--show-current"]) do
      {result, 0} -> {:ok, String.trim(result)}
      error -> error
    end
  end

  def commit(path, message, opts \\ []) do
    add_all = Keyword.get(opts, :add_all, false)
    if add_all, do: System.cmd("git", ["-C", path, "add", "-A"])
    case System.cmd("git", ["-C", path, "commit", "-m", message]) do
      {result, 0} -> {:ok, String.trim(result)}
      error -> error
    end
  end

  def diff(path, opts \\ []) do
    args = ["-C", path, "diff"]
    args = if Keyword.get(opts, :staged), do: args ++ ["--cached"], else: args
    case System.cmd("git", args) do
      {result, 0} -> {:ok, result}
      error -> error
    end
  end

  def log(path, opts \\ []) do
    count = Keyword.get(opts, :count, 10)
    case System.cmd("git", ["-C", path, "log", "--oneline", "-#{count}"]) do
      {result, 0} -> {:ok, String.split(String.trim(result), "\n")}
      error -> error
    end
  end

  def stash(path, message \\ nil) do
    args = ["-C", path, "stash"]
    args = if message, do: args ++ ["push", "-m", message], else: args ++ ["push"]
    case System.cmd("git", args) do
      {result, 0} -> {:ok, String.trim(result)}
      error -> error
    end
  end

  defp parse_status(output) do
    output
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      <<status::binary-size(2), " ", path::binary>> = line
      {String.trim(status), path}
    end)
  end
end
