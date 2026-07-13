defmodule PiCodingAgent.Utils.Shell do
  @moduledoc "Shell detection and helpers."
  def detect_shell do
    System.get_env("SHELL") || default_shell()
  end

  def shell_name do
    detect_shell() |> Path.basename()
  end

  def shell_args(command) do
    case shell_name() do
      "fish" -> ["-c", command]
      "zsh" -> ["-c", command]
      "bash" -> ["-c", command]
      "sh" -> ["-c", command]
      "powershell" -> ["-Command", command]
      "pwsh" -> ["-Command", command]
      _ -> ["-c", command]
    end
  end

  def interactive? do
    System.get_env("TERM") != nil and IO.ANSI.enabled?()
  end

  def tty? do
    case :io.columns() do
      {:ok, _} -> true
      _ -> false
    end
  end

  def terminal_size do
    case :io.columns() do
      {:ok, cols} -> cols
      _ -> 80
    end
  end

  defp default_shell do
    case :os.type() do
      {:win32, _} -> "powershell"
      _ -> "/bin/sh"
    end
  end
end
