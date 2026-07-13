defmodule PiAi.Provider.OpenAICodexModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.OpenAICodex.models()) >= 1
end
