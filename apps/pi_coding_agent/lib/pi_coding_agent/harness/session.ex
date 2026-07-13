defmodule PiCodingAgent.Harness.Session do
  @moduledoc "Session storage and retrieval for the harness."
  def save(session_id, data, dir \\ nil) do
    session_dir = dir || Path.expand("~/.pi/agent/sessions")
    File.mkdir_p!(session_dir)
    path = Path.join(session_dir, "#{session_id}.json")
    File.write!(path, JSON.encode!(data))
    :ok
  end

  def load(session_id, dir \\ nil) do
    session_dir = dir || Path.expand("~/.pi/agent/sessions")
    path = Path.join(session_dir, "#{session_id}.json")
    case File.read(path) do
      {:ok, content} ->
        case JSON.decode(content) do
          {:ok, data} -> {:ok, data}
          err -> err
        end
      err -> err
    end
  end
end
