defmodule PiCodingAgent.ExportHTML do
  @moduledoc """
  Exports a conversation session as a standalone HTML file.
  """

  alias PiAi.Message

  @template """
  <!DOCTYPE html>
  <html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>pi conversation</title>
    <style>
      body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 800px; margin: 0 auto; padding: 20px; background: #0d1117; color: #c9d1d9; }
      .msg { margin: 12px 0; padding: 12px; border-radius: 8px; }
      .user { background: #1f2937; border-left: 3px solid #3b82f6; }
      .assistant { background: #1f2937; border-left: 3px solid #22c55e; }
      .system { background: #1f2937; border-left: 3px solid #eab308; }
      .tool { background: #1f2937; border-left: 3px solid #a855f7; font-size: 0.9em; }
      .label { font-size: 0.8em; color: #8b949e; margin-bottom: 6px; }
      .content { white-space: pre-wrap; word-wrap: break-word; }
      pre { background: #161b22; padding: 12px; border-radius: 6px; overflow-x: auto; }
    </style>
  </head>
  <body>
    <h2>pi conversation</h2>
    <p style="color: #8b949e;">{{date}}</p>
    {{messages}}
  </body>
  </html>
  """

  @doc """
  Exports a list of messages as an HTML file.
  """
  @spec export([Message.t()], String.t()) :: :ok
  def export(messages, output_path \\ "conversation.html") do
    rendered_messages =
      messages
      |> Enum.map(&render_message/1)
      |> Enum.join("\n")

    date = DateTime.utc_now() |> DateTime.to_string() |> String.slice(0, 19)

    html =
      @template
      |> String.replace("{{date}}", date)
      |> String.replace("{{messages}}", rendered_messages)

    File.write!(output_path, html)
    IO.puts(:stderr, "Exported to #{output_path}")
    :ok
  end

  defp render_message(%Message{role: role, content: content} = msg) do
    role_class = Atom.to_string(role)
    label = String.capitalize(Atom.to_string(role))

    extra =
      if msg.name do
        " (#{msg.name})"
      else
        ""
      end

    escaped = escape_html(content || "")
    ~s(<div class="msg #{role_class}"><div class="label">#{label}#{extra}</div><div class="content">#{escaped}</div></div>)
  end

  defp escape_html(text) do
    text
    |> String.replace("&", "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("\n", "<br>")
    |> String.replace("  ", "&nbsp;&nbsp;")
  end
end
