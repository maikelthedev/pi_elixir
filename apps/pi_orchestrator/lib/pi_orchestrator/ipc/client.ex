defmodule PiOrchestrator.IPC.Client do
  @moduledoc "IPC client for communicating with orchestrator instances over TCP."
  use GenServer
  defstruct [:host, :port, :socket]

  def start_link(opts) do
    host = Keyword.get(opts, :host, "127.0.0.1")
    port = Keyword.get(opts, :port, 45678)
    GenServer.start_link(__MODULE__, {host, port}, name: opts[:name] || __MODULE__)
  end

  def init({host, port}) do
    case :gen_tcp.connect(String.to_charlist(host), port, [:binary, packet: :line, active: false], 5000) do
      {:ok, socket} -> {:ok, %__MODULE__{host: host, port: port, socket: socket}}
      {:error, reason} -> {:stop, "Connection failed: #{inspect(reason)}"}
    end
  end

  def spawn(pid, opts) do
    req = PiOrchestrator.IPC.Protocol.encode(%{type: :spawn, cwd: opts[:cwd] || File.cwd!(), label: opts[:label], provider: opts[:provider], model: opts[:model]})
    :gen_tcp.send(pid, req <> "\n")
    recv_response(pid)
  end

  def list(pid) do
    req = PiOrchestrator.IPC.Protocol.encode(%{type: :list})
    :gen_tcp.send(pid, req <> "\n")
    recv_response(pid)
  end

  def stop(pid, instance_id) do
    req = PiOrchestrator.IPC.Protocol.encode(%{type: :stop, instance_id: instance_id})
    :gen_tcp.send(pid, req <> "\n")
    recv_response(pid)
  end

  defp recv_response(socket) do
    case :gen_tcp.recv(socket, 0, 5000) do
      {:ok, data} -> {:ok, PiOrchestrator.IPC.Protocol.decode(data)}
      {:error, reason} -> {:error, reason}
    end
  end
end
