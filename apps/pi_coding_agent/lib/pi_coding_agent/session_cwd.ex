defmodule PiCodingAgent.SessionCwd do
  @moduledoc "Session working directory management."
  @doc "Resolves the effective session cwd from options."
  def resolve(opts) do
    Keyword.get(opts, :cwd) || Keyword.get(opts, :project_dir) || File.cwd!()
  end
  @doc "Returns true if the path is within the session's working directory."
  def within?(session_cwd, path), do: String.starts_with?(Path.expand(path), Path.expand(session_cwd))
end
