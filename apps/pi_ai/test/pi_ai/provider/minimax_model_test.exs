defmodule PiAi.Provider.MinimaxModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.Minimax.models()) >= 1
end
