defmodule PiOrchestrator.Serve do
  @moduledoc "Simple HTTP server for orchestrator API using Erlang :inets."
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    port = Keyword.get(opts, :port, 4000)
    handler = Keyword.get(opts, :handler, PiOrchestrator.Handler)
    {:ok, %{port: port, handler: handler, server_ref: nil}}
  end

  def handle_call(:start, _from, state) do
    case :inets.start(:httpd, [
      port: state.port,
      server_name: 'pi-orchestrator',
      server_root: '/tmp',
      document_root: '/tmp',
      modules: [PiOrchestrator.HttpHandler]
    ]) do
      {:ok, ref} -> {:reply, :ok, %{state | server_ref: ref}}
      {:error, reason} -> {:reply, {:error, reason}, state}
    end
  end

  def handle_call(:stop, _from, state) do
    if state.server_ref, do: :inets.stop(:httpd, state.server_ref)
    {:reply, :ok, %{state | server_ref: nil}}
  end
end

defmodule PiOrchestrator.HttpHandler do
  @moduledoc "HTTP handler for orchestrator REST API."
  def doHEAD(req, _env), do: doResponse(req, 200, "")
  def doGET(req, _env) do
    path = :mod_esi.get_path(req)
    case path do
      '/status' -> doResponse(req, 200, JSON.encode!(%{status: "ok"}))
      '/health' -> doResponse(req, 200, JSON.encode!(%{status: "ok"}))
      _ -> doResponse(req, 404, JSON.encode!(%{error: "Not found"}))
    end
  end

  def doPOST(req, _env) do
    body = :mod_esi.get_content(req)
    case JSON.decode(body) do
      {:ok, %{"method" => method, "params" => params}} ->
        case PiOrchestrator.Handler.handle_request(method, params || %{}) do
          {:ok, result} -> doResponse(req, 200, JSON.encode!(result))
          {:error, msg} -> doResponse(req, 400, JSON.encode!(%{error: msg}))
        end
      _ -> doResponse(req, 400, JSON.encode!(%{error: "Invalid JSON"}))
    end
  end

  defp doResponse(req, code, body) do
    :mod_esi.send_response(req, {code, [{~c"content-type", ~c"application/json"}], body})
  end
end
