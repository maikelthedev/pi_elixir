defmodule PiCodingAgent.Utils.Deprecation do
  @moduledoc "Deprecation warning utilities."
  require Logger

  def warn(old_name, new_name, version \\ nil) do
    msg = if version, do: "#{old_name} is deprecated since #{version}, use #{new_name} instead",
    else: "#{old_name} is deprecated, use #{new_name} instead"
    Logger.warning(msg)
  end

  def warn_once(key, old_name, new_name, version \\ nil) do
    unless Process.get({:deprecation_warned, key}) do
      Process.put({:deprecation_warned, key}, true)
      warn(old_name, new_name, version)
    end
  end
end
