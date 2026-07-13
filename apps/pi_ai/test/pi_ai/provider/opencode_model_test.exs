defmodule PiAi.Provider.OpenCodeModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.OpenCode.models()) >= 1
end
