defmodule PiCodingAgent.Utils.Clipboard do
  @moduledoc "Clipboard abstraction for cross-platform copy/paste."

  def copy(text) do
    case :os.type() do
      {:unix, :darwin} -> cmd("pbcopy", text)
      {:unix, :linux} -> cmd("xclip -selection clipboard", text) || cmd("xsel --clipboard --input", text)
      {:win32, _} -> cmd("clip", text)
      _ -> {:error, :unsupported}
    end
  end

  def paste do
    case :os.type() do
      {:unix, :darwin} -> read("pbpaste")
      {:unix, :linux} -> read("xclip -selection clipboard -o") || read("xsel --clipboard --output")
      {:win32, _} -> read("powershell -command Get-Clipboard")
      _ -> {:error, :unsupported}
    end
  end

  defp cmd(command, text) do
    port = Port.open({:spawn, command}, [:binary, :hide])
    Port.command(port, text)
    Port.close(port)
    :ok
  end

  defp read(command) do
    case System.cmd("sh", ["-c", command], stderr_to_stdout: true) do
      {result, 0} -> {:ok, String.trim_trailing(result)}
      _ -> {:error, :not_available}
    end
  end
end
