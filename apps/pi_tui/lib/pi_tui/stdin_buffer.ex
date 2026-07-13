defmodule PiTui.StdinBuffer do
  @moduledoc """
  Buffers stdin input for line-based and character-based reading.

  Essential for handling escape sequences (like arrow keys) that
  arrive as multiple bytes.
  """

  defstruct [:buffer, pending_key: nil]

  @type t :: %__MODULE__{buffer: String.t(), pending_key: PiTui.Keys.key() | nil}

  @doc "Creates a new stdin buffer."
  def new, do: %__MODULE__{buffer: ""}

  @doc "Feeds bytes into the buffer and tries to extract a key."
  def feed(%__MODULE__{buffer: buf} = sb, bytes) do
    combined = buf <> bytes
    {key, rest} = PiTui.Keys.parse(combined)
    {%{sb | buffer: rest, pending_key: key}, key}
  end

  @doc "Returns the pending key if available."
  def pending(%__MODULE__{pending_key: key} = sb) do
    {sb, key}
  end

  @doc "Clears the pending key."
  def clear(%__MODULE__{} = sb), do: %{sb | pending_key: nil}

  @doc "Returns true if the buffer has unconsumed bytes."
  def has_pending?(%__MODULE__{buffer: buf}), do: buf != ""
end
