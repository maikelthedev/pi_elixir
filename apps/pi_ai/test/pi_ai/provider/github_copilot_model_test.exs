defmodule PiAi.Provider.GitHubCopilotModelTest do
  use ExUnit.Case, async: true
  test "models returns GitHub Copilot models" do
    assert length(PiAi.Provider.GitHubCopilot.models()) >= 1
  end
end
