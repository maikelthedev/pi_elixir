defmodule PiAi.Utils.AbortSignals do
  @moduledoc "Abort signal handling for cancelling API requests."
  defstruct [:ref, :aborted, :callbacks]

  def new do
    %__MODULE__{ref: make_ref(), aborted: false, callbacks: []}
  end

  def abort(signal) do
    send(self(), {:abort, signal.ref})
    %{signal | aborted: true}
  end

  def aborted?(%__MODULE__{aborted: ab}), do: ab

  def on_abort(%__MODULE__{} = signal, callback) do
    %{signal | callbacks: [callback | signal.callbacks]}
  end

  def check(%__MODULE__{aborted: true}), do: {:error, :aborted}
  def check(%__MODULE__{}), do: :ok

  def wait(%__MODULE__{ref: ref}) do
    receive do
      {:abort, ^ref} -> {:error, :aborted}
    after
      0 -> :ok
    end
  end
end
