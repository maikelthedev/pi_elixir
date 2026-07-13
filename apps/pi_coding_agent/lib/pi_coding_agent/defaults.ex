defmodule PiCodingAgent.Defaults do
  @moduledoc "Default configuration values for the coding agent."

  @defaults %{
    model: "anthropic/claude-sonnet-4-20250514",
    max_turns: 100,
    max_tokens: 128_000,
    theme: "dark",
    log_level: :info,
    compact_threshold: 80_000,
    rpc_port: 4001,
    session_dir: "~/.pi/sessions",
    editor: "vim",
    auto_compact: true,
    thinking_enabled: true,
    diff_enabled: true,
    save_interval: 60_000
  }

  def get(key), do: Map.get(@defaults, key)
  def get(key, default), do: Map.get(@defaults, key, default)
  def all, do: @defaults

  def for_env(:test) do
    %{
      model: "faux/test",
      max_turns: 5,
      max_tokens: 1000,
      theme: "dark",
      log_level: :warning,
      compact_threshold: 1000,
      rpc_port: 4002,
      session_dir: "/tmp/pi_test_sessions",
      editor: "cat",
      auto_compact: false,
      thinking_enabled: false,
      diff_enabled: true,
      save_interval: 1_000
    }
  end

  def for_env(:production), do: @defaults
  def for_env(:development), do: Map.merge(@defaults, %{log_level: :debug, max_turns: 200})
  def for_env(_), do: @defaults
end
