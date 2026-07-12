defmodule PiAi.Model do
  @moduledoc """
  Represents an LLM model with its metadata.

  ## Fields
    - `id` - model identifier (e.g. "claude-sonnet-4-20250514")
    - `name` - human-readable name
    - `provider` - provider identifier (e.g. "anthropic")
    - `api` - API type (e.g. "anthropic-messages", "openai-responses")
    - `base_url` - optional custom base URL
    - `context_window` - max context window in tokens
    - `max_tokens` - max output tokens
    - `input_cost` - cost per 1M input tokens
    - `output_cost` - cost per 1M output tokens
    - `cache_read_cost` - cost per 1M cache read tokens
    - `cache_write_cost` - cost per 1M cache write tokens
  """

  defstruct [
    :id,
    :name,
    :provider,
    :api,
    :base_url,
    context_window: 0,
    max_tokens: 0,
    input_cost: 0.0,
    output_cost: 0.0,
    cache_read_cost: 0.0,
    cache_write_cost: 0.0
  ]

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          provider: String.t(),
          api: String.t(),
          base_url: String.t() | nil,
          context_window: non_neg_integer(),
          max_tokens: non_neg_integer(),
          input_cost: float(),
          output_cost: float(),
          cache_read_cost: float(),
          cache_write_cost: float()
        }
end
