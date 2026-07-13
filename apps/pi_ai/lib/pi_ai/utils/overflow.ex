defmodule PiAi.Utils.Overflow do
  @moduledoc "Output overflow handling for large tool outputs."
  def truncate_output(output, max_bytes \\ 100_000) do
    if byte_size(output) <= max_bytes do
      output
    else
      half = div(max_bytes, 2)
      head = binary_part(output, 0, half)
      tail_start = byte_size(output) - half
      tail = binary_part(output, tail_start, half)
      head <> "\n\n... [#{byte_size(output) - max_bytes} bytes truncated] ...\n\n" <> tail
    end
  end

  def truncate_lines(output, max_lines \\ 1000) do
    lines = String.split(output, "\n")
    if length(lines) <= max_lines do
      output
    else
      {kept, dropped} = Enum.split(lines, max_lines)
      Enum.join(kept, "\n") <> "\n\n... [#{length(dropped)} more lines] ..."
    end
  end

  def fits?(output, max_bytes \\ 100_000), do: byte_size(output) <= max_bytes
end
