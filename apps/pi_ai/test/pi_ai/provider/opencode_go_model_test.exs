defmodule PiAi.Provider.OpenCodeGoModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.OpenCodeGo.models()) >= 1
end
