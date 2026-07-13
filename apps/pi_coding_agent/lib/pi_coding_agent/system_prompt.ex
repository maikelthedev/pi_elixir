defmodule PiCodingAgent.SystemPrompt do
  @moduledoc """
  Builds the system prompt for the agent, including rules,
  skills, and context from configuration.
  """

  @doc """
  Builds the full system prompt from components.
  """
  @spec build(keyword()) :: String.t()
  def build(opts \\ []) do
    model = Keyword.get(opts, :model, "")
    skills = Keyword.get(opts, :skills, [])
    project_rules = Keyword.get(opts, :project_rules, [])
    extra_instructions = Keyword.get(opts, :instructions, "")

    parts = []

    parts = parts ++ [core_prompt(model)]

    parts = if skills != [], do: parts ++ [skill_prompt(skills)], else: parts
    parts = if project_rules != [], do: parts ++ [rule_prompt(project_rules)], else: parts
    parts = if extra_instructions != "", do: parts ++ [extra_instructions], else: parts

    Enum.join(parts, "\n\n")
  end

  defp core_prompt(model) do
    """
    You are pi, a coding agent running in Elixir.
    You help users by reading files, executing commands, editing code, and writing new files.

    Current model: #{model}

    Available tools:
    - read: Read file contents with offset/limit
    - write: Write content to files
    - edit: Make precise text replacements
    - edit_diff: Apply search/replace diffs
    - bash: Execute shell commands
    - grep: Search file contents
    - ls: List directory contents
    - find: Find files matching a pattern
    - truncate: Truncate files to N lines

    Follow the user's instructions carefully. Think step by step.
    """
  end

  defp skill_prompt(skills) do
    "Available skills:\n#{Enum.map_join(skills, "\n", &"  - #{&1}")}"
  end

  defp rule_prompt(rules) do
    "Project rules:\n#{Enum.map_join(rules, "\n", &"  - #{&1}")}"
  end

  @doc """
  Loads project rules from AGENTS.md and CLAUDE.md files.
  """
  @spec load_project_rules(String.t()) :: [String.t()]
  def load_project_rules(project_dir \\ File.cwd!()) do
    for file <- ["AGENTS.md", "CLAUDE.md", ".pi/rules.md"] do
      path = Path.join(project_dir, file)
      case File.read(path) do
        {:ok, content} -> ["From #{file}:\n#{content}"]
        {:error, _} -> nil
      end
    end
    |> Enum.reject(&is_nil/1)
    |> List.flatten()
  end
end
