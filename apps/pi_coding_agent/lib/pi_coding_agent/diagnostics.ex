defmodule PiCodingAgent.Diagnostics do
  @moduledoc """
  Diagnostics collection for troubleshooting pi configuration.
  """

  @doc """
  Collects and returns diagnostic information.
  """
  @spec collect() :: map()
  def collect do
    %{
      "version" => "0.1.0",
      "elixir_version" => System.version(),
      "providers" => provider_info(),
      "sessions" => session_info(),
      "extensions" => extension_info(),
      "settings" => setting_info(),
      "system" => system_info()
    }
  end

  @doc """
  Prints diagnostic information to stderr.
  """
  @spec print() :: :ok
  def print do
    info = collect()

    IO.puts(:stderr, "pi Diagnostics")
    IO.puts(:stderr, "  Version: #{info["version"]}")
    IO.puts(:stderr, "  Elixir: #{info["elixir_version"]}")
    IO.puts(:stderr, "  Providers: #{length(info["providers"])} loaded, #{length(info["providers"])} total models")
    IO.puts(:stderr, "  Sessions: #{info["sessions"]["count"]} saved")
    IO.puts(:stderr, "  Extensions: #{info["extensions"]["count"]} installed")
    IO.puts(:stderr, "  System: #{info["system"]["os_type"]} / #{info["system"]["n_cpus"]} CPUs")

    IO.puts(:stderr, "\n  Loaded providers:")
    Enum.each(info["providers"], fn p ->
      IO.puts(:stderr, "    - #{p["name"]} (#{p["model_count"]} models)")
    end)

    :ok
  end

  defp provider_info do
    providers = PiAi.Providers.loaded_providers()

    Enum.map(providers, fn mod ->
      models =
        if function_exported?(mod, :models, 0) do
          apply(mod, :models, [])
        else
          []
        end

      %{
        "name" => mod |> Atom.to_string() |> String.replace("Elixir.", ""),
        "model_count" => length(models)
      }
    end)
  end

  defp session_info do
    sessions = PiCodingAgent.Session.list()
    %{"count" => length(sessions)}
  end

  defp extension_info do
    exts = PiCodingAgent.Extension.load_all()
    %{"count" => length(exts)}
  end

  defp setting_info do
    try do
      PiCodingAgent.Settings.load()
    rescue
      _ -> %{}
    end
  end

  defp system_info do
    %{
      "os_type" => (:os.type() |> elem(0) |> Atom.to_string()),
      "n_cpus" => :erlang.system_info(:logical_processors),
      "cwd" => File.cwd!()
    }
  rescue
    _ -> %{"os_type" => "unknown"}
  end
end
