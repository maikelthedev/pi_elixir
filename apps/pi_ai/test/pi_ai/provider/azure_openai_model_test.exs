defmodule PiAi.Provider.AzureOpenAIModelTest do
  use ExUnit.Case, async: true
  test "models returns Azure OpenAI models" do
    assert length(PiAi.Provider.AzureOpenAI.models()) >= 1
  end
end
