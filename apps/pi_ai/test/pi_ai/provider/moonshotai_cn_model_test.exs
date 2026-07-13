defmodule PiAi.Provider.MoonshotAICNModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.MoonshotAICN.models()) >= 1
end
