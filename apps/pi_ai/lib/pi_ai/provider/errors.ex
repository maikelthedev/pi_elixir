defmodule PiAi.Provider.Errors do
  @moduledoc "Provider-specific error types, messages, and recovery strategies."
  defstruct [:code, :message, :retryable, :recoverable, :provider, :status_code]

  @type t :: %__MODULE__{
    code: String.t(), message: String.t(), retryable: boolean(),
    recoverable: boolean(), provider: String.t(), status_code: integer() | nil
  }

  def parse("anthropic", status, body) do
    err = body["error"] || %{}
    %__MODULE__{
      code: err["type"] || "unknown",
      message: err["message"] || inspect(body),
      retryable: status in [429, 500, 502, 503],
      recoverable: status in [401, 403],
      provider: "anthropic",
      status_code: status
    }
  end

  def parse("openai", status, body) do
    err = body["error"] || %{}
    %__MODULE__{
      code: err["type"] || "unknown",
      message: err["message"] || inspect(body),
      retryable: status in [429, 500, 502, 503],
      recoverable: status in [401, 403],
      provider: "openai",
      status_code: status
    }
  end

  def parse(provider, status, body) do
    %__MODULE__{
      code: "http_#{status}",
      message: inspect(body),
      retryable: status in [429, 500, 502, 503],
      recoverable: status in [401, 403],
      provider: provider,
      status_code: status
    }
  end

  def format(%__MODULE__{code: c, message: m, retryable: r, status_code: s}) do
    retry = if r, do: " (retryable)", else: ""
    "[#{s}] #{c}: #{m}#{retry}"
  end
end
