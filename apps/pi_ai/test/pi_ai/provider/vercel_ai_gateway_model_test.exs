defmodule PiAi.Provider.VercelAIGatewayModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.VercelAIGateway.models()) >= 1
end
