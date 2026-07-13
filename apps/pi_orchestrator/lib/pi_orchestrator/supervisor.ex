defmodule PiOrchestrator.Supervisor do
  @moduledoc "Top-level orchestrator supervisor. Starts IPC server, handler, storage, sessions."
  use Supervisor
  require Logger
  alias PiOrchestrator.Config

  def start_link(opts) do
    Supervisor.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    config = Config.from_env() |> Config.merge(opts)
    children = [
      {PiOrchestrator.Storage, name: PiOrchestrator.Storage, dir: config.storage_dir},
      {PiOrchestrator.SessionSupervisor, name: PiOrchestrator.SessionSupervisor},
      {PiOrchestrator.Handler, name: PiOrchestrator.Handler, storage: PiOrchestrator.Storage, config: config},
      {PiOrchestrator.IPC.Server, name: PiOrchestrator.IPC.Server, port: config.port, handler: PiOrchestrator.Handler}
    ]
    Logger.info("Orchestrator starting on #{config.host}:#{config.port}")
    Supervisor.init(children, strategy: :one_for_one)
  end
end
