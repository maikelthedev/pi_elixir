defmodule PiAi.Provider.DeepSeekModelTest do
  use ExUnit.Case, async: true
  test "models returns deepseek models" do
    models = PiAi.Provider.DeepSeek.models()
    assert length(models) >= 2
  end
end
