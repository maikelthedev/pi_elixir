defmodule PiOrchestrator.CLI do
  @moduledoc "Orchestrator CLI entry point."
  def main(argv) do
    case argv do
      ["serve" | rest] -> serve(rest)
      ["status" | rest] -> status(rest)
      ["stop" | rest] -> stop(rest)
      _ -> help()
    end
  end

  defp serve(args) do
    port = parse_port(args)
    config = PiOrchestrator.Config.from_env()
    config = %{config | port: port}
    Application.put_env(:pi_orchestrator, :config, config)
    {:ok, _} = Application.ensure_all_started(:pi_orchestrator)
    IO.puts("Orchestrator listening on port #{port}")
    Process.sleep(:infinity)
  end

  defp status(_args) do
    # Try to connect and get status
    case HTTPClient.get("http://localhost:4000/status") do
      {:ok, resp} -> IO.puts(resp)
      {:error, _} -> IO.puts("Orchestrator not running")
    end
  end

  defp stop(_args) do
    IO.puts("Stopping orchestrator...")
    System.halt(0)
  end

  defp help do
    IO.puts("""
    pi-orchestrator - Session orchestrator

    Usage: pi-orchestrator <command> [options]

    Commands:
      serve [--port PORT]   Start the orchestrator server
      status                Check orchestrator status
      stop                  Stop the orchestrator
      help                  Show this help
    """)
  end

  defp parse_port(args) do
    case args do
      ["--port", port | _] -> String.to_integer(port)
      _ -> 4000
    end
  end
end
