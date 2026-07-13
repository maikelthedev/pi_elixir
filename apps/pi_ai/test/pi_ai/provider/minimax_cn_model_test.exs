defmodule PiAi.Provider.MinimaxCNModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.MinimaxCN.models()) >= 1
end
