defmodule PiAi.ProviderTest do
  use ExUnit.Case, async: true

  describe "behaviour" do
    test "valid provider module implements the behaviour" do
      defmodule TestProvider do
        @behaviour PiAi.Provider

        def stream_chat(_model, _messages, _opts), do: {:ok, []}
        def models, do: [%{id: "test-model"}]
      end

      assert function_exported?(TestProvider, :stream_chat, 3)
      assert function_exported?(TestProvider, :models, 0)
    end
  end
end
