defmodule PiCodingAgent.Experimental do
  @moduledoc "Manages experimental feature flags."
  @features %{
    streaming_render: false,
    auto_compact: false,
    branch_on_fork: false,
    predictive_input: false
  }
  def enabled?(feature), do: Map.get(@features, feature, false)
  def list, do: @features
  def enable(feature), do: put_in(@features, [feature], true)
  def disable(feature), do: put_in(@features, [feature], false)
end
