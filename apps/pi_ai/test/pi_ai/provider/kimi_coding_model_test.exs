defmodule PiAi.Provider.KimiCodingModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.KimiCoding.models()) >= 1
end
