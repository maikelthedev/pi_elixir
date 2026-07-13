defmodule PiCodingAgent.Component.EarendilAnnouncement do
  @moduledoc "End-of-session stats and tips."
  def render(stats \\ %{}) do
    msgs = Map.get(stats, :messages, 0)
    tokens = Map.get(stats, :tokens, 0)
    model = Map.get(stats, :model, "?")
    cost = Map.get(stats, :cost, 0)
    time = Map.get(stats, :time, "?")
    [PiTui.Terminal.styled(" Session Summary ", :reverse),
     "",
     "  Model: #{PiTui.Terminal.styled(model, :cyan)}",
     "  Messages: #{msgs}  Tokens: #{tokens}  Cost: $#{Float.round(cost / 1, 6)}",
     "  Time: #{time}",
     "  #{PiTui.Terminal.styled("Happy coding!", :dim)}",
     ""]
  end
end
