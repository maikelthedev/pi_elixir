defmodule PiCodingAgent.Component.AssistantMessage do
  @moduledoc "Renders an assistant message with markdown and tool calls."
  alias PiAi.Message

  def render(%Message{role: :assistant, content: content, tool_calls: calls}, width \\ 70) do
    header = "#{PiTui.Terminal.styled("AI:", :cyan)}"
    body = if content, do: PiTui.Component.Markdown.render(content, width), else: []
    tool_blocks = render_tool_calls(calls || [])
    [header] ++ body ++ tool_blocks ++ [""]
  end

  def render_tool_calls([]), do: []
  def render_tool_calls(calls) do
    Enum.map(calls, fn tc ->
      func = tc["function"] || tc[:function]
      name = func["name"] || func[:name] || "?"
      args = func["arguments"] || func[:arguments] || "{}"
      PiTui.Terminal.styled("  └─ #{name}(#{String.slice(args, 0, 40)})", :yellow)
    end)
  end
end
