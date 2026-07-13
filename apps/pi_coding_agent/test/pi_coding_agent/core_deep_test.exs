defmodule PiCodingAgent.CoreDeepTest do
  use ExUnit.Case, async: true

  test "FooterDataProvider renders" do
    footer = PiCodingAgent.Core.FooterDataProvider.new(model: "claude-sonnet", status: :idle, messages: 5)
    result = PiCodingAgent.Core.FooterDataProvider.render(footer)
    assert is_binary(result)
    assert result =~ "claude-sonnet"
  end

  test "FooterDataProvider default" do
    footer = PiCodingAgent.Core.FooterDataProvider.new()
    assert footer.model == ""
    assert footer.status == :idle
  end

  test "PromptTemplates renders with bindings" do
    pt = PiCodingAgent.Core.PromptTemplates.new()
    assert {:ok, result} = PiCodingAgent.Core.PromptTemplates.render(pt, "system")
    assert is_binary(result)

    assert {:ok, result} = PiCodingAgent.Core.PromptTemplates.render(pt, "compact", conversation: "hello")
    assert result =~ "hello"
  end

  test "PromptTemplates renders with render!" do
    pt = PiCodingAgent.Core.PromptTemplates.new()
    result = PiCodingAgent.Core.PromptTemplates.render!(pt, "system")
    assert is_binary(result)
  end

  test "PromptTemplates template not found" do
    pt = PiCodingAgent.Core.PromptTemplates.new()
    assert {:error, :template_not_found} = PiCodingAgent.Core.PromptTemplates.render(pt, "nonexistent")
  end

  test "PromptTemplates add and remove" do
    pt = PiCodingAgent.Core.PromptTemplates.new()
    pt = PiCodingAgent.Core.PromptTemplates.add(pt, "custom", "Hello {{name}}")
    assert {:ok, "Hello world"} = PiCodingAgent.Core.PromptTemplates.render(pt, "custom", name: "world")
    pt = PiCodingAgent.Core.PromptTemplates.remove(pt, "custom")
    assert {:error, :template_not_found} = PiCodingAgent.Core.PromptTemplates.render(pt, "custom")
  end

  test "PromptTemplates list" do
    pt = PiCodingAgent.Core.PromptTemplates.new()
    names = PiCodingAgent.Core.PromptTemplates.list(pt)
    assert "system" in names
    assert "compact" in names
  end

  test "Keybindings resolves" do
    kb = PiCodingAgent.Core.Keybindings.new()
    assert :submit = PiCodingAgent.Core.Keybindings.resolve(kb, :enter)
    assert :new_line = PiCodingAgent.Core.Keybindings.resolve(kb, :ctrl_o)
    assert :char = PiCodingAgent.Core.Keybindings.resolve(kb, :unknown)
  end

  test "Keybindings rebind" do
    kb = PiCodingAgent.Core.Keybindings.new()
    kb = PiCodingAgent.Core.Keybindings.rebind(kb, :ctrl_x, :custom)
    assert :custom = PiCodingAgent.Core.Keybindings.resolve(kb, :ctrl_x)
  end

  test "Keybindings list_actions" do
    kb = PiCodingAgent.Core.Keybindings.new()
    actions = PiCodingAgent.Core.Keybindings.list_actions(kb)
    assert is_map(actions)
    assert Map.has_key?(actions, :submit)
  end

  test "SlashCommands executes help" do
    sc = PiCodingAgent.Core.SlashCommands.new()
    assert {:ok, text} = PiCodingAgent.Core.SlashCommands.execute(sc, "/help")
    assert text =~ "Available commands"
  end

  test "SlashCommands executes version" do
    sc = PiCodingAgent.Core.SlashCommands.new()
    assert {:ok, text} = PiCodingAgent.Core.SlashCommands.execute(sc, "/version")
    assert text =~ "0.1.0"
  end

  test "SlashCommands returns action for clear" do
    sc = PiCodingAgent.Core.SlashCommands.new()
    assert {:action, :clear} = PiCodingAgent.Core.SlashCommands.execute(sc, "/clear")
  end

  test "SlashCommands unknown command" do
    sc = PiCodingAgent.Core.SlashCommands.new()
    assert {:error, _} = PiCodingAgent.Core.SlashCommands.execute(sc, "/nonexistent")
  end

  test "SlashCommands list" do
    sc = PiCodingAgent.Core.SlashCommands.new()
    commands = PiCodingAgent.Core.SlashCommands.list(sc)
    assert "help" in commands
    assert "model" in commands
  end

  test "ProviderAttribution display_name" do
    assert "Anthropic" = PiCodingAgent.Core.ProviderAttribution.display_name("anthropic")
    assert "OpenAI" = PiCodingAgent.Core.ProviderAttribution.display_name("openai")
    assert "unknown" = PiCodingAgent.Core.ProviderAttribution.display_name("unknown")
  end

  test "ProviderAttribution color" do
    assert :orange = PiCodingAgent.Core.ProviderAttribution.color("anthropic")
    assert :green = PiCodingAgent.Core.ProviderAttribution.color("openai")
  end

  test "ProviderDisplayNames display_name" do
    assert "Claude Sonnet" = PiCodingAgent.Core.ProviderDisplayNames.display_name("claude-sonnet")
    assert "Gpt 4" = PiCodingAgent.Core.ProviderDisplayNames.display_name("gpt-4")
  end

  test "ProviderDisplayNames provider_display_name" do
    assert "Openai" = PiCodingAgent.Core.ProviderDisplayNames.provider_display_name("openai")
    assert "Deepseek" = PiCodingAgent.Core.ProviderDisplayNames.provider_display_name("deepseek")
  end

  test "ProviderDisplayNames short_name" do
    assert "claude-sonnet" = PiCodingAgent.Core.ProviderDisplayNames.short_name("anthropic/claude-sonnet")
  end

  test "OutputGuard guards output" do
    guard = PiCodingAgent.Core.OutputGuard.new(max_bytes: 100, max_lines: 5)
    big = String.duplicate("x", 200)
    result = PiCodingAgent.Core.OutputGuard.guard(guard, big)
    assert byte_size(result) < 200
  end

  test "OutputGuard fits?" do
    guard = PiCodingAgent.Core.OutputGuard.new(max_bytes: 100, max_lines: 5)
    assert PiCodingAgent.Core.OutputGuard.fits?(guard, "short")
    refute PiCodingAgent.Core.OutputGuard.fits?(guard, String.duplicate("x", 200))
  end

  test "PackageManager detects" do
    assert {:ok, :mix} = PiCodingAgent.Core.PackageManager.detect("/home/maikel/code/pi_elixir")
  end

  test "PackageManager install_cmd" do
    assert "mix deps.get" = PiCodingAgent.Core.PackageManager.install_cmd(:mix)
    assert "npm install" = PiCodingAgent.Core.PackageManager.install_cmd(:npm)
  end

  test "PackageManager test_cmd" do
    assert "mix test" = PiCodingAgent.Core.PackageManager.test_cmd(:mix)
  end

  test "PackageManager build_cmd" do
    assert "mix compile" = PiCodingAgent.Core.PackageManager.build_cmd(:mix)
  end

  test "PackageManager name" do
    assert "Mix (Elixir)" = PiCodingAgent.Core.PackageManager.name(:mix)
  end

  test "ModelResolver resolves full path" do
    assert {:ok, _} = PiCodingAgent.Core.ModelResolver.resolve("anthropic/claude")
  end

  test "ModelResolver nil returns error" do
    assert {:error, :nil_model} = PiCodingAgent.Core.ModelResolver.resolve(nil)
  end

  test "ModelRegistry new struct" do
    registry = %PiCodingAgent.Core.ModelRegistry{models: %{}, aliases: %{}, default_model: "test"}
    assert registry.default_model == "test"
  end
end
