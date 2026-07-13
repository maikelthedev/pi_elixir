defmodule PiAi.Provider.ZAIModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.ZAI.models()) >= 1
end
