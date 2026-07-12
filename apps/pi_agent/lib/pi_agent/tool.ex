defmodule PiAgent.Tool do
  @moduledoc """
  Behaviour for coding agent tools.

  All tools must implement `call/2` to execute the tool and
  `schema/0` to return a JSON Schema describing the tool's parameters.
  """

  @doc """
  Execute the tool with the given arguments and context.

  Returns `{:ok, result}` on success or `{:error, reason}` on failure.
  """
  @callback call(args :: map(), context :: map()) :: {:ok, term()} | {:error, term()}

  @doc """
  Returns a JSON Schema map describing this tool's parameters.

  The schema is used by the LLM to understand what arguments the tool accepts.
  """
  @callback schema() :: map()
end
