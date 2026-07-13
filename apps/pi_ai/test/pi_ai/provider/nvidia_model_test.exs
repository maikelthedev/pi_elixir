defmodule PiAi.Provider.NVIDIAModelTest do
  use ExUnit.Case, async: true
  test "models returns NVIDIA models" do
    assert length(PiAi.Provider.NVIDIA.models()) >= 1
  end
end
