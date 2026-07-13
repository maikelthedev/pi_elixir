defmodule PiOrchestrator.RpcProcess do
  @moduledoc "Manages an external RPC process (e.g., a pi coding-agent running in RPC mode)."
  use GenServer
  require Logger

  defstruct [:port, :buffer, :pending, :id, :status]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  def init(opts) do
    command = Keyword.fetch!(opts, :command)
    id = Keyword.get(opts, :id, generate_id())
    port = Port.open({:spawn, command}, [:binary, :line, :stderr_to_stdout])
    {:ok, %__MODULE__{port: port, buffer: "", pending: %{}, id: id, status: :running}}
  end

  def send_request(pid, method, params) do
    GenServer.call(pid, {:send_request, method, params}, 30_000)
  end

  def status(pid), do: GenServer.call(pid, :status)
  def stop(pid), do: GenServer.stop(pid, :normal)

  def handle_call({:send_request, method, params}, from, state) do
    request_id = generate_id()
    msg = JSON.encode!(%{id: request_id, method: method, params: params})
    Port.command(state.port, msg <> "\n")
    pending = Map.put(state.pending, request_id, {from, System.monotonic_time()})
    {:noreply, %{state | pending: pending}}
  end

  def handle_call(:status, _from, state), do: {:reply, state.status, state}

  def handle_info({port, {:data, data}}, %{port: port} = state) do
    buffer = state.buffer <> data
    {lines, rest} = split_lines(buffer)
    state = %{state | buffer: rest}
    state = Enum.reduce(lines, state, fn line, acc -> process_line(line, acc) end)
    {:noreply, state}
  end

  def handle_info({port, :closed}, %{port: port} = state) do
    Logger.info("RPC process #{state.id} exited")
    {:noreply, %{state | status: :stopped}}
  end

  defp process_line(line, state) do
    case JSON.decode(line) do
      {:ok, %{"id" => id, "result" => result}} ->
        case Map.pop(state.pending, id) do
          {nil, pending} -> %{state | pending: pending}
          {{from, _ts}, pending} ->
            GenServer.reply(from, {:ok, result})
            %{state | pending: pending}
        end
      {:ok, %{"id" => id, "error" => error}} ->
        case Map.pop(state.pending, id) do
          {nil, pending} -> %{state | pending: pending}
          {{from, _ts}, pending} ->
            GenServer.reply(from, {:error, error})
            %{state | pending: pending}
        end
      _ -> state
    end
  end

  defp split_lines(buffer) do
    case String.split(buffer, "\n", parts: 2) do
      [line, rest] -> {[line], rest}
      [line] -> if String.ends_with?(line, "\n"), do: {[String.trim_trailing(line, "\n")], ""}, else: {[], line}
    end
  end

  defp generate_id, do: :crypto.strong_rand_bytes(6) |> Base.encode16(case: :lower)
end
