defmodule PiOrchestrator.IPC.Server do
  @moduledoc "IPC server that accepts connections and dispatches orchestration commands."
  use GenServer
  defstruct [:port, :listen_socket, :sessions]

  def start_link(opts) do
    port = Keyword.get(opts, :port, 45678)
    GenServer.start_link(__MODULE__, port, name: opts[:name] || __MODULE__)
  end

  def init(port) do
    case :gen_tcp.listen(port, [:binary, packet: :line, reuseaddr: true, active: false]) do
      {:ok, socket} ->
        IO.puts(:stderr, "IPC server listening on port #{port}")
        {:ok, %__MODULE__{port: port, listen_socket: socket, sessions: %{}}, {:continue, :accept}}
      {:error, reason} -> {:stop, "Failed to listen: #{inspect(reason)}"}
    end
  end

  def handle_continue(:accept, state) do
    case :gen_tcp.accept(state.listen_socket) do
      {:ok, client} -> handle_client(client, state)
      {:error, _} -> :ok
    end
    {:noreply, state, {:continue, :accept}}
  end

  defp handle_client(socket, state) do
    case :gen_tcp.recv(socket, 0, 1000) do
      {:ok, data} ->
        req = PiOrchestrator.IPC.Protocol.decode(data)
        response = handle_request(req, state)
        :gen_tcp.send(socket, PiOrchestrator.IPC.Protocol.encode(response) <> "\n")
      {:error, :timeout} -> :ok
      {:error, _} -> :ok
    end
    :gen_tcp.close(socket)
  end

  defp handle_request(%{type: :spawn} = req, state) do
    model = if req[:model] do
      case PiAi.Providers.find_model(req.model) do
        {:ok, m} -> m
        _ -> hd(PiAi.Providers.all_models())
      end
    else
      hd(PiAi.Providers.all_models())
    end
    {:ok, pid} = PiAgent.Agent.start_link(model: model)
    id = "inst_#{:erlang.unique_integer([:positive])}"
    %{type: :spawn, instance_id: id, pid: pid}
  end

  defp handle_request(%{type: :list}, state) do
    children = Supervisor.which_children(PiOrchestrator.SessionSupervisor)
    instances = Enum.map(children, fn {id, pid, _type, _mod} -> %{id: id, pid: pid} end)
    %{type: :list, instances: instances}
  end

  defp handle_request(_req, _state), do: %{type: :error, code: "unknown", message: "Unknown request type"}
end
