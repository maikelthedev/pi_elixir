defmodule PiAi.Provider do
  @moduledoc """
  Behaviour for LLM provider implementations.

  All providers must implement `stream_chat/3` at minimum.
  The optional `models/0` callback returns a list of available models.
  """

  @doc """
  Stream a chat completion from the provider.

  Returns `{:ok, enumerable}` where the enumerable yields
  event chunks, or `{:error, reason}`.
  """
  @callback stream_chat(model :: PiAi.Model.t(), messages :: [PiAi.Message.t()], opts :: keyword()) ::
              {:ok, Enumerable.t()} | {:error, term()}

  @doc """
  Returns available models for this provider.
  """
  @callback models() :: [PiAi.Model.t()]

  @optional_callbacks models: 0
end
