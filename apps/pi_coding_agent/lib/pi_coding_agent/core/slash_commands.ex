defmodule PiCodingAgent.Core.SlashCommands do
  @moduledoc "Slash command handling for interactive mode."
  defstruct [:commands]

  def new do
    commands = %{
      "help" => &help/1,
      "model" => &model/1,
      "models" => &models/1,
      "clear" => &clear/1,
      "compact" => &compact/1,
      "save" => &save/1,
      "load" => &load/1,
      "settings" => &settings/1,
      "theme" => &theme/1,
      "debug" => &debug/1,
      "exit" => &exit_cmd/1,
      "quit" => &exit_cmd/1,
      "version" => &version_cmd/1,
      "skills" => &skills_cmd/1,
      "extensions" => &extensions_cmd/1,
      "auth" => &auth_cmd/1,
      "provider" => &provider_cmd/1,
      "trust" => &trust_cmd/1
    }
    %__MODULE__{commands: commands}
  end

  def execute(%__MODULE__{commands: commands}, input) do
    case parse_command(input) do
      {:ok, cmd, args} ->
        case Map.get(commands, cmd) do
          nil -> {:error, "Unknown command: #{cmd}. Type /help for available commands."}
          func -> func.(args)
        end
      {:error, _} = err -> err
    end
  end

  def list(%__MODULE__{commands: commands}), do: Map.keys(commands) |> Enum.sort()

  defp parse_command(input) do
    input = String.trim_leading(input, "/")
    case String.split(input, " ", parts: 2) do
      [cmd] -> {:ok, cmd, ""}
      [cmd, args] -> {:ok, cmd, args}
      [] -> {:error, :empty}
    end
  end

  defp help(_args), do: {:ok, help_text()}
  defp model(args), do: {:ok, "Current model: #{args}"}
  defp models(_args), do: {:ok, "Use /model <name> to switch models"}
  defp clear(_args), do: {:action, :clear}
  defp compact(_args), do: {:action, :compact}
  defp save(_args), do: {:action, :save}
  defp load(_args), do: {:action, :load}
  defp settings(_args), do: {:ok, "Settings: use /settings <key> <value>"}
  defp theme(_args), do: {:ok, "Theme: use /theme <name>"}
  defp debug(_args), do: {:action, :debug}
  defp exit_cmd(_args), do: {:action, :exit}
  defp version_cmd(_args), do: {:ok, "pi coding agent v0.1.0"}
  defp skills_cmd(_args), do: {:ok, "Skills loaded from ~/.pi/skills/"}
  defp extensions_cmd(_args), do: {:ok, "Extensions loaded from ~/.pi/extensions/"}
  defp auth_cmd(_args), do: {:ok, "Auth: use /auth <provider> to authenticate"}
  defp provider_cmd(_args), do: {:ok, "Provider: use /provider <name> to switch"}
  defp trust_cmd(_args), do: {:action, :trust}

  defp help_text do
    """
    Available commands:
      /help - Show this help
      /model <name> - Set model
      /models - List models
      /clear - Clear messages
      /compact - Compact conversation
      /save - Save session
      /load - Load session
      /settings - View settings
      /theme <name> - Set theme
      /debug - Debug info
      /exit - Exit
      /version - Version info
      /skills - List skills
      /extensions - List extensions
      /auth <provider> - Authenticate
      /provider <name> - Set provider
      /trust - Trust project
    """
  end
end
