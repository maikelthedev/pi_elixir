defmodule PiCodingAgent.Migrations do
  @moduledoc """
  Schema migration system for session files and settings.

  Handles upgrading old session/configuration formats
  to the current version.
  """

  @doc "Runs all pending migrations."
  def run(force \\ false) do
    version = get_version()
    migrations_to_run = Enum.filter(migrations(), fn {v, _name, _fun} -> v > version end)

    if migrations_to_run == [] and not force do
      :noop
    else
      Enum.reduce(migrations_to_run, version, fn {v, name, fun}, _current ->
        IO.puts(:stderr, "Running migration v#{v}: #{name}")
        fun.()
        set_version(v)
        v
      end)

      :ok
    end
  end

  @doc "Returns the current schema version."
  def get_version do
    PiCodingAgent.Settings.get("schema_version", 0)
  end

  defp set_version(v) do
    PiCodingAgent.Settings.set("schema_version", v)
  end

  defp migrations do
    [
      {1, "Migrate sessions to new branch format", &migrate_v1/0}
    ]
  end

  defp migrate_v1 do
    # In v1, we just ensure session directories exist
    File.mkdir_p!(Path.expand("~/.pi/agent/sessions"))
    File.mkdir_p!(Path.expand("~/.pi/agent/extensions"))
    :ok
  end
end
