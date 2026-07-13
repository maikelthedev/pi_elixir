defmodule PiCodingAgent.Component.EarendilAnnouncementTest do
  use ExUnit.Case, async: true
  test "renders with stats" do
    result = PiCodingAgent.Component.EarendilAnnouncement.render(%{messages: 5, model: "gpt-4o"})
    assert Enum.join(result) =~ "gpt-4o"
  end
end
