defmodule PiAi.Provider.XiaomiModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.Xiaomi.models()) >= 1
end
