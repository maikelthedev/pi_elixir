defmodule PiAi.Message do
  @moduledoc """
  Represents a message in a conversation with an LLM.

  ## Fields
    - `role` - `:user`, `:assistant`, `:system`, or `:tool`
    - `content` - text content (string or list of content blocks)
    - `tool_calls` - list of tool call maps (assistant messages only)
    - `tool_call_id` - tool call ID (tool result messages only)
    - `name` - tool name (tool result messages only)
    - `is_error` - whether this is an error result
  """

  defstruct [:role, :content, :tool_calls, :tool_call_id, :name, is_error: false]

  @type role :: :user | :assistant | :system | :tool

  @type t :: %__MODULE__{
          role: role(),
          content: String.t() | list(),
          tool_calls: list() | nil,
          tool_call_id: String.t() | nil,
          name: String.t() | nil,
          is_error: boolean()
        }
end
