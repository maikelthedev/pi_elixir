defmodule PiAgent.Harness.Session.JSONLRepo do
  @moduledoc "JSONL file-based session storage (persistent)."
  use GenServer

  defstruct [:path, :buffer]

  def start_link(opts) do
    path = Keyword.get(opts, :path, Path.expand("~/.pi/agent/sessions"))
    GenServer.start_link(__MODULE__, path, name: opts[:name] || __MODULE__)
  end

  def init(path) do
    File.mkdir_p!(path)
    {:ok, %__MODULE__{path: path, buffer: []}}
  end

  def save(session_id, entries) do
    GenServer.cast(__MODULE__, {:save, session_id, entries})
  end

  def load(session_id) do
    GenServer.call(__MODULE__, {:load, session_id})
  end
end
