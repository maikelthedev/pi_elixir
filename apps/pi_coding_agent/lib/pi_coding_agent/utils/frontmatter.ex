defmodule PiCodingAgent.Utils.Frontmatter do
  @moduledoc "YAML frontmatter parsing from markdown and text files."
  @frontmatter_regex ~r/\A---\n(.*?)\n---\n(.*)\z/s

  def parse(text) do
    case Regex.run(@frontmatter_regex, text) do
      [_, yaml_content, body] ->
        case parse_yaml(yaml_content) do
          {:ok, metadata} -> {:ok, metadata, body}
          error -> error
        end
      nil -> {:ok, %{}, text}
    end
  end

  def parse!(text) do
    case parse(text) do
      {:ok, metadata, body} -> {metadata, body}
      {:error, reason} -> raise ArgumentError, "Failed to parse frontmatter: #{inspect(reason)}"
    end
  end

  defp parse_yaml(content) do
    content
    |> String.split("\n", trim: true)
    |> Enum.reduce_while({:ok, %{}}, fn line, {:ok, acc} ->
      case String.split(line, ":", parts: 2) do
        [key, value] ->
          key = String.trim(key) |> String.to_atom()
          value = String.trim(value) |> unquote_value()
          {:cont, {:ok, Map.put(acc, key, value)}}
        _ -> {:cont, {:ok, acc}}
      end
    end)
  end

  defp unquote_value("\"" <> rest), do: String.trim_trailing(rest, "\"")
  defp unquote_value("'" <> rest), do: String.trim_trailing(rest, "'")
  defp unquote_value("true"), do: true
  defp unquote_value("false"), do: false
  defp unquote_value(value) do
    case Integer.parse(value) do
      {int, ""} -> int
      _ -> value
    end
  end
end
