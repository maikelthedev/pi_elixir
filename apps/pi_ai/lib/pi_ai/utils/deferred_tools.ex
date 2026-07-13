defmodule PiAi.Utils.DeferredTools do
  @moduledoc "Deferred tool definitions that are loaded lazily."
  defstruct [:tools, :loaded_at]

  def new do
    %__MODULE__{tools: %{}, loaded_at: nil}
  end

  def register(deferred, name, definition_fn) do
    %{deferred | tools: Map.put(deferred.tools, name, definition_fn)}
  end

  def resolve(deferred, name) do
    case Map.get(deferred.tools, name) do
      nil -> {:error, :not_found}
      func when is_function(func) ->
        tool = func.()
        {:ok, tool}
    end
  end

  def resolve_all(deferred) do
    deferred.tools
    |> Enum.map(fn {name, func} -> {name, func.()} end)
    |> Map.new()
  end

  def list(deferred), do: Map.keys(deferred.tools)
  def count(deferred), do: map_size(deferred.tools)
end
