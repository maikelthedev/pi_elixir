defmodule PiCodingAgent.TrustManager do
  @moduledoc "Project trust state management. Controls whether the agent can execute tools."
  use GenServer
  require Logger

  @trust_levels [:untrusted, :limited, :trusted]

  defstruct [:project_dir, trust_level: :untrusted, trusted_paths: [], remember: false]

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: opts[:name] || __MODULE__)
  end

  def init(opts) do
    project_dir = Keyword.get(opts, :project_dir, File.cwd!())
    trust_level = load_trust(project_dir)
    {:ok, %__MODULE__{project_dir: project_dir, trust_level: trust_level}}
  end

  def trust_level(pid \\ __MODULE__), do: GenServer.call(pid, :trust_level)
  def trusted?(pid \\ __MODULE__), do: GenServer.call(pid, :trusted?)

  def set_trust(pid \\ __MODULE__, level) when level in @trust_levels do
    GenServer.call(pid, {:set_trust, level})
  end

  def can_execute?(pid \\ __MODULE__, tool_name) do
    level = trust_level(pid)
    case level do
      :trusted -> true
      :limited -> tool_name not in ["bash"]
      :untrusted -> false
    end
  end

  def handle_call(:trust_level, _from, state), do: {:reply, state.trust_level, state}
  def handle_call(:trusted?, _from, state), do: {:reply, state.trust_level == :trusted, state}
  def handle_call({:set_trust, level}, _from, state) do
    save_trust(state.project_dir, level)
    {:reply, :ok, %{state | trust_level: level}}
  end

  defp trust_file(dir), do: Path.join(dir, ".pi-trust")

  defp load_trust(dir) do
    case File.read(trust_file(dir)) do
      {:ok, content} ->
        try do
          content |> String.trim() |> String.to_existing_atom()
        rescue
          _ -> :untrusted
        end
      _ -> :untrusted
    end
  end

  defp save_trust(dir, level) do
    File.write!(trust_file(dir), to_string(level))
    Logger.info("Trust level set to #{level} for #{dir}")
  end

  defp rescue_to(func, default) do
    func.()
  rescue
    _ -> default
  end
end
