defmodule PiAi.Utils.JsonParse do
  @moduledoc "Safe JSON parsing with fallback handling."
  def safe_decode(input) do
    case JSON.decode(input) do
      {:ok, _} = result -> result
      {:error, _} -> try_fix_and_decode(input)
    end
  end

  def safe_decode!(input) do
    case safe_decode(input) do
      {:ok, value} -> value
      {:error, error} -> raise ArgumentError, "JSON parse error: #{inspect(error)}"
    end
  end

  def extract_json(text) do
    case Regex.run(~r/\{.*\}/s, text) do
      [match] -> safe_decode(match)
      _ -> {:error, :no_json_found}
    end
  end

  defp try_fix_and_decode(input) do
    fixed = input
    |> String.trim()
    |> fix_trailing_commas()
    |> fix_unquoted_keys()
    JSON.decode(fixed)
  end

  defp fix_trailing_commas(text), do: Regex.replace(~r/,\s*([\]}])/, text, "\\1")
  defp fix_unquoted_keys(text), do: Regex.replace(~r/(\w+):/, text, "\"\\1\":")
end
