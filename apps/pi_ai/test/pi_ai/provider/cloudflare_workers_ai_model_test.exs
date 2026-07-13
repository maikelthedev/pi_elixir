defmodule PiAi.Provider.CloudflareWorkersAIModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.CloudflareWorkersAI.models()) >= 1
end
