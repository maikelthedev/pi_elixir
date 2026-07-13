defmodule PiAi.Provider.ZAICodingCNModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.ZAICodingCN.models()) >= 1
end
