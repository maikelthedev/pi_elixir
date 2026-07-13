defmodule PiCodingAgent.Core.OutputGuard do
  @moduledoc "Guards against excessive output from tools and commands."
  defstruct [:max_bytes, :max_lines, :max_depth]

  def default do
    %__MODULE__{
      max_bytes: 100_000,
      max_lines: 1000,
      max_depth: 50
    }
  end

  def new(opts \\ []) do
    struct(default(), opts)
  end

  def guard(%__MODULE__{} = guard, output) when is_binary(output) do
    output
    |> check_bytes(guard.max_bytes)
    |> check_lines(guard.max_lines)
  end

  defp check_bytes(output, max) when byte_size(output) > max do
    half = div(max, 2)
    head = binary_part(output, 0, half)
    tail = binary_part(output, byte_size(output) - half, half)
    head <> "\n\n... [#{byte_size(output) - max} bytes truncated] ...\n\n" <> tail
  end
  defp check_bytes(output, _), do: output

  defp check_lines(output, max) do
    lines = String.split(output, "\n")
    if length(lines) > max do
      {kept, _dropped} = Enum.split(lines, max)
      Enum.join(kept, "\n") <> "\n\n... [#{length(lines) - max} more lines] ..."
    else
      output
    end
  end

  def fits?(%__MODULE__{} = guard, output) when is_binary(output) do
    byte_size(output) <= guard.max_bytes and
    length(String.split(output, "\n")) <= guard.max_lines
  end
end
