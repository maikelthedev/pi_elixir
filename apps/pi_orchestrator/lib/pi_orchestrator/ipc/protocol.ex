defmodule PiOrchestrator.IPC.Protocol do
  @moduledoc "IPC protocol types and serialization for orchestrator communication."

  @type spawn_request :: %{type: :spawn, cwd: String.t(), label: String.t() | nil, provider: String.t() | nil, model: String.t() | nil}
  @type list_request :: %{type: :list}
  @type stop_request :: %{type: :stop, instance_id: String.t()}
  @type status_request :: %{type: :status, instance_id: String.t()}
  @type rpc_request :: %{type: :rpc, instance_id: String.t(), command: map()}
  @type request :: spawn_request | list_request | stop_request | status_request | rpc_request

  @type spawn_response :: %{type: :spawn, instance_id: String.t(), pid: pid()}
  @type list_response :: %{type: :list, instances: [map()]}
  @type stop_response :: %{type: :stop, success: boolean()}
  @type status_response :: %{type: :status, status: String.t(), uptime: integer()}
  @type rpc_response :: %{type: :rpc, result: term()}
  @type error_response :: %{type: :error, code: String.t(), message: String.t()}
  @type response :: spawn_response | list_response | stop_response | status_response | rpc_response | error_response

  def encode(request), do: JSON.encode!(request)
  def decode(json), do: JSON.decode!(json)
end
