defmodule PiOrchestrator.Handler do
  @moduledoc "Handles incoming requests from IPC server, routes to sessions."
  use GenServer
  require Logger
  alias PiOrchestrator.Storage
  alias PiOrchestrator.SessionSupervisor

  defstruct [:storage, :config, sessions: %{}, requests: %{}]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    config = Keyword.get(opts, :config, %{})
    storage = Keyword.get(opts, :storage, Storage)
    {:ok, %__MODULE__{storage: storage, config: config}}
  end

  def handle_request(pid \\ __MODULE__, method, params) do
    GenServer.call(pid, {:handle_request, method, params}, 30_000)
  end

  def handle_call({:handle_request, "session.create", params}, _from, state) do
    id = generate_id()
    case SessionSupervisor.start_session(id, params) do
      {:ok, _pid} -> {:reply, {:ok, %{"session_id" => id}}, state}
      error -> {:reply, error, state}
    end
  end

  def handle_call({:handle_request, "session.send", %{"session_id" => sid, "message" => msg}}, _from, state) do
    case SessionSupervisor.send_message(sid, msg) do
      {:ok, response} -> {:reply, {:ok, %{"response" => response}}, state}
      error -> {:reply, error, state}
    end
  end

  def handle_call({:handle_request, "session.get", %{"session_id" => sid}}, _from, state) do
    case state.storage.load(sid) do
      {:ok, messages} -> {:reply, {:ok, %{"messages" => messages}}, state}
      error -> {:reply, error, state}
    end
  end

  def handle_call({:handle_request, "session.list", _params}, _from, state) do
    sessions = state.storage.list_sessions()
    {:reply, {:ok, %{"sessions" => sessions}}, state}
  end

  def handle_call({:handle_request, "session.delete", %{"session_id" => sid}}, _from, state) do
    SessionSupervisor.stop_session(sid)
    state.storage.delete_session(sid)
    {:reply, {:ok, %{}}, state}
  end

  def handle_call({:handle_request, "model.list", _params}, _from, state) do
    models = PiAi.ModelRegistry.list() |> Enum.map(fn m -> %{id: m.id, name: m.name, provider: m.provider} end)
    {:reply, {:ok, %{"models" => models}}, state}
  end

  def handle_call({:handle_request, "status", _params}, _from, state) do
    sessions = SessionSupervisor.active_sessions()
    {:reply, {:ok, %{"status" => "ok", "active_sessions" => length(sessions), "version" => "0.1.0"}}, state}
  end

  def handle_call({:handle_request, method, _params}, _from, state) do
    {:reply, {:error, "Unknown method: #{method}"}, state}
  end

  defp generate_id, do: :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
end
