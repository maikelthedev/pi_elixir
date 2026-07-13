defmodule PiAi.Provider.CloudflareAIGatewayModelTest do
  use ExUnit.Case, async: true; test "models", do: assert length(PiAi.Provider.CloudflareAIGateway.models()) >= 1
end
