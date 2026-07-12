defmodule PiCodingAgent.Tool.Bash do
  @moduledoc """
  Tool to execute shell commands.

  Wraps System.cmd for synchronous execution with timeout support.
  """
  @behaviour PiAgent.Tool

  @impl true
  def call(%{command: cmd} = args, _context) do
    timeout = Map.get(args, :timeout, 30_000)

    task =
      Task.async(fn ->
        System.cmd("sh", ["-c", cmd],
          into: [],
          stderr_to_stdout: true,
          env: %{"PATH" => System.get_env("PATH") || "/usr/local/bin:/usr/bin:/bin"}
        )
      end)

    case Task.yield(task, timeout) || Task.shutdown(task, :brutal_kill) do
      {:ok, {output, _exit_code}} ->
        text = IO.iodata_to_binary(output)
        {:ok, text}

      nil ->
        {:error, "Command timed out after #{timeout}ms"}
    end
  end

  @impl true
  def schema do
    %{
      type: "object",
      properties: %{
        command: %{type: "string", description: "Shell command to execute"},
        timeout: %{type: "integer", description: "Timeout in milliseconds", default: 30_000}
      },
      required: [:command]
    }
  end
end
