defmodule PiOrchestrator.Config do
  @moduledoc "Orchestrator configuration with sensible defaults."
  @default_port 4000
  @default_host "0.0.0.0"
  @default_max_sessions 100
  @default_session_timeout 3_600_000
  defstruct [:port, :host, :auth_token, :storage_dir, :max_sessions, :session_timeout,
             :log_level, :metrics_enabled]

  @type t :: %__MODULE__{
    port: integer(), host: String.t(), auth_token: String.t() | nil,
    storage_dir: String.t(), max_sessions: integer(), session_timeout: integer(),
    log_level: atom(), metrics_enabled: boolean()
  }

  def from_env do
    %__MODULE__{
      port: env_int("PORT", @default_port),
      host: env_str("HOST", @default_host),
      auth_token: System.get_env("AUTH_TOKEN"),
      storage_dir: env_str("STORAGE_DIR", Path.join(System.user_home(), ".pi/sessions")),
      max_sessions: env_int("MAX_SESSIONS", @default_max_sessions),
      session_timeout: env_int("SESSION_TIMEOUT", @default_session_timeout),
      log_level: env_atom("LOG_LEVEL", :info),
      metrics_enabled: env_bool("METRICS_ENABLED", false)
    }
  end

  def merge(config, overrides) when is_map(overrides), do: Map.merge(config, overrides)
  def merge(config, overrides) when is_list(overrides), do: struct(config, overrides)

  defp env_int(key, default) do
    case System.get_env(key) do
      nil -> default
      val ->
        case Integer.parse(val) do
          {v, _} -> v
          _ -> default
        end
    end
  end

  defp env_str(key, default), do: System.get_env(key) || default

  defp env_atom(key, default) do
    case System.get_env(key) do
      nil -> default
      val -> String.to_existing_atom(val)
    end
  rescue
    _ -> default
  end

  defp env_bool(key, default), do: System.get_env(key) == "true" or default
end
