defmodule PiAi.Provider.AntLingModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.AntLing.models()) >= 1
end
