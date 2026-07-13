defmodule PiCodingAgent.SourceInfo do
  @moduledoc "Tracks source attribution for models, tools, and settings."
  defstruct [:type, :name, :source, version: nil, timestamp: nil]
  def new(type, name, source, opts \\ []), do: %__MODULE__{type: type, name: name, source: source, version: Keyword.get(opts, :version), timestamp: Keyword.get(opts, :timestamp)}
  def format(%__MODULE__{type: t, name: n, source: s}), do: "#{n} (#{t} from #{s})"
end
