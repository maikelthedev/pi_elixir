defmodule PiCodingAgent.SlashCommands do
  @moduledoc """
  Slash command registry and dispatch for the interactive mode.
  """

  @commands %{
    "help" => "Show available commands",
    "clear" => "Clear the conversation",
    "save" => "Save the current session",
    "sessions" => "List saved sessions",
    "export" => "Export conversation as HTML",
    "models" => "List available models",
    "model" => "Switch model: /model <id>",
    "diagnostics" => "Show system diagnostics",
    "compact" => "Compact the conversation",
    "branches" => "List conversation branches",
    "fork" => "Create a new branch: /fork <name>",
    "switch" => "Switch branch: /switch <name>",
    "exit" => "Exit pi"
  }

  @doc "Returns the full command registry."
  def registry, do: @commands

  @doc "Returns a help string for all commands."
  def help do
    Enum.map(@commands, fn {cmd, desc} ->
      "  /#{String.pad_trailing(cmd, 15)} #{desc}"
    end)
    |> Enum.join("\n")
  end

  @doc "Returns true if the text starts with a slash command."
  def is_command?(text), do: String.starts_with?(text, "/")

  @doc "Parses a slash command into {command, args}."
  def parse(text) do
    [cmd | args] = String.split(text, " ", parts: 2)
    {String.trim_leading(cmd, "/"), args |> List.first() |> then(&(&1 || ""))}
  end
end
