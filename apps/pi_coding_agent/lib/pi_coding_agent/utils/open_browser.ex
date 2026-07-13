defmodule PiCodingAgent.Utils.OpenBrowser do
  @moduledoc "Cross-platform browser opening."
  def open(url) do
    case :os.type() do
      {:unix, :darwin} -> System.cmd("open", [url])
      {:unix, :linux} -> System.cmd("xdg-open", [url])
      {:win32, _} -> System.cmd("cmd", ["/c", "start", url])
      _ -> {:error, :unsupported}
    end
  end
end
