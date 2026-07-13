defmodule PiCodingAgent.Component.UserMessage do
  @moduledoc "Renders a user message."
  alias PiAi.Message
  def render(%Message{role: :user, content: content}, width \\ 70) do
    header = "#{PiTui.Terminal.styled("You:", :green)}"
    body = wrap_text(content || "", width)
    [header] ++ Enum.map(body, &"  #{&1}") ++ [""]
  end
  defp wrap_text(text, width) do
    text |> String.split("\n") |> Enum.flat_map(fn line ->
      if String.length(line) <= width, do: [line], else: do_wrap(line, width, [])
    end)
  end
  defp do_wrap("", _, acc), do: Enum.reverse(acc)
  defp do_wrap(text, w, acc) do
    if String.length(text) <= w, do: Enum.reverse([text | acc]), else: do_wrap(String.slice(text, w..-1//1), w, [String.slice(text, 0, w) | acc])
  end
end
