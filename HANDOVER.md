# pi Elixir — Rewrite Handover

## Project Location

```
/home/maikel/code/pi_elixir
```

The project is an Elixir umbrella app that aims to replicate the functionality of the TypeScript [pi coding agent](https://github.com/earendil-works/pi) (212k lines, 808 files) as a clean Elixir implementation.

## Current State

| Metric | Value |
|--------|-------|
| Commits | 42 |
| Modules | 124 |
| Lines | ~8,300 |
| Test files | 52 |
| Tests | 163 passing |
| Warnings | 0 |
| Branch | `main` |
| Target Elixir | 1.18.4 (nixpkgs) |

## How to Work

```bash
# Enter dev shell (only way to get Elixir — NixOS)
nix-shell -p elixir --run "mix test"

# Build escript
cd apps/pi_coding_agent && nix-shell -p elixir --run "mix escript.build"

# Run the CLI
./pi --help
```

## Project Structure

```
pi_elixir/
├── mix.exs                          # Umbrella root
├── config/config.exs
├── apps/
│   ├── pi_ai/                       # LLM provider layer
│   │   ├── lib/pi_ai/
│   │   │   ├── provider/            # 29 provider implementations
│   │   │   ├── providers.ex         # Provider registry
│   │   │   ├── model_registry.ex    # File-persisted model cache
│   │   │   ├── message.ex           # Message struct
│   │   │   ├── model.ex             # Model struct
│   │   │   ├── auth.ex              # API key storage
│   │   │   ├── event_stream.ex      # SSE parser
│   │   │   ├── images.ex            # Image generation
│   │   │   └── provider.ex          # Behaviour
│   │   └── test/                    # 52 tests
│   │
│   ├── pi_agent/                    # Agent runtime
│   │   ├── lib/pi_agent/
│   │   │   ├── agent.ex             # Agent GenServer
│   │   │   ├── loop.ex              # Agent loop (OpenAI/Anthropic/Gemini formats)
│   │   │   ├── tool.ex              # Tool behaviour
│   │   │   └── tool/registry.ex     # Tool registry GenServer
│   │   └── test/                    # 13 tests
│   │
│   ├── pi_tui/                      # Terminal UI library (28 modules)
│   │   ├── lib/pi_tui/
│   │   │   ├── component/           # 13 components
│   │   │   │   ├── editor.ex        # Multi-line editor
│   │   │   │   ├── input.ex         # Single-line input w/ history
│   │   │   │   ├── markdown.ex      # Markdown renderer
│   │   │   │   ├── footer.ex        # Status bar
│   │   │   │   ├── select_list.ex   # Scrollable list
│   │   │   │   ├── box.ex           # Bordered boxes
│   │   │   │   ├── loader.ex        # Spinner
│   │   │   │   ├── cancellable_loader.ex
│   │   │   │   ├── autocomplete.ex  # Dropdown suggestions
│   │   │   │   ├── text.ex          # Wrap/truncate
│   │   │   │   ├── spacer.ex
│   │   │   │   ├── truncated_text.ex
│   │   │   │   └── settings_list.ex
│   │   │   ├── keys.ex              # Escape sequence parser
│   │   │   ├── keybindings.ex       # Key→action mapping
│   │   │   ├── kill_ring.ex         # Emacs-style kill ring
│   │   │   ├── undo_stack.ex        # Undo/redo
│   │   │   ├── word_navigation.ex   # Word-level cursor
│   │   │   ├── stdin_buffer.ex      # Byte buffering
│   │   │   ├── terminal.ex          # ANSI escapes
│   │   │   ├── terminal_colors.ex   # 256-color + truecolor
│   │   │   ├── terminal_image.ex    # Kitty protocol
│   │   │   ├── fuzzy.ex             # Fuzzy matching
│   │   │   ├── differential_renderer.ex  # Screen diff
│   │   │   ├── native_modifiers.ex  # Cmd/Ctrl handling
│   │   │   ├── tui.ex               # Main framework
│   │   │   └── utils.ex             # Helpers
│   │   └── test/                    # 39 tests
│   │
│   ├── pi_coding_agent/             # CLI + tools + modes (largest app)
│   │   ├── lib/pi_coding_agent/
│   │   │   ├── cli.ex               # CLI entry point
│   │   │   ├── mode/
│   │   │   │   ├── interactive.ex   # Full TUI chat mode
│   │   │   │   ├── print.ex         # One-shot mode
│   │   │   │   └── rpc.ex           # JSON-RPC mode
│   │   │   ├── tool/                # 9 tools
│   │   │   │   ├── read.ex, write.ex, edit.ex, edit_diff.ex
│   │   │   │   ├── bash.ex, grep.ex, ls.ex, find.ex
│   │   │   │   └── truncate.ex
│   │   │   ├── session.ex           # Save/load conversations
│   │   │   ├── session_manager.ex   # Branching session tree
│   │   │   ├── session_picker.ex
│   │   │   ├── session_selector.ex  # Interactive picker
│   │   │   ├── session_cwd.ex
│   │   │   ├── settings.ex          # Global + project settings
│   │   │   ├── extension.ex         # Load .ex files
│   │   │   ├── compaction.ex        # Conversation summarization
│   │   │   ├── event_bus.ex         # Pub/sub lifecycle
│   │   │   ├── system_prompt.ex     # Agent instructions builder
│   │   │   ├── slash_commands.ex    # /command registry
│   │   │   ├── skills.ex            # SKILL.md loader/executor
│   │   │   ├── oauth.ex             # Device code flow
│   │   │   ├── telemetry.ex         # Timing + token tracking
│   │   │   ├── http_dispatcher.ex   # Proxy config
│   │   │   ├── migrations.ex        # Schema versions
│   │   │   ├── package_manager.ex   # Extension install/list/remove
│   │   │   ├── diagnostics.ex       # System info collection
│   │   │   ├── export_html.ex       # Conversation→HTML
│   │   │   ├── project_trust.ex     # Trust prompts
│   │   │   ├── resource_loader.ex   # Global + project dirs
│   │   │   ├── output_guard.ex      # Stdout takeover
│   │   │   ├── startup_ui.ex        # First-time setup
│   │   │   ├── harness.ex           # Agent harness
│   │   │   ├── harness/session.ex
│   │   │   ├── harness/prompt_templates.ex
│   │   │   ├── auth_guidance.ex
│   │   │   ├── cache_stats.ex
│   │   │   ├── provider_attribution.ex
│   │   │   ├── provider_display_names.ex
│   │   │   ├── resolve_config_value.ex
│   │   │   ├── source_info.ex
│   │   │   └── experimental.ex
│   │   └── test/                    # 58 tests
│   │
│   └── pi_orchestrator/             # Experimental supervisor tree
│       ├── lib/pi_orchestrator/
│       │   ├── session_supervisor.ex
│       │   └── ...supervisor
│       └── test/                    # 1 test
```

## Key Design Decisions

1. **Built-in JSON** — Elixir 1.17+ ships `JSON` module. No Jason dependency.
2. **`:req` only** — HTTP client. No hackney. `OpenAICompat` module shared by all OpenAI-compatible providers.
3. **No Erlang-style modules** — Pure Elixir idioms throughout. GenServer, Supervisor, Task, etc.
4. **TDD** — Tests written first for core modules. Red-green-refactor.
5. **Small commits** — 42 conventional commits, each a single logical change.
6. **Escript entry point** — `PiCodingAgent.CLI.main/1`. Build with `mix escript.build` from `apps/pi_coding_agent/`.

## What's Built (Feature Parity Summary)

The TypeScript pi has ~808 files / 212k lines. This Elixir version has 124 modules / 8.3k lines covering all major feature areas:

- **Core LLM infrastructure**: 29 providers, SSE streaming, model registry, auth
- **Agent runtime**: Tool behaviour, Registry GenServer, Agent GenServer, Loop
- **TUI**: 28 modules (editor, input, markdown, keys, keybindings, etc.)
- **Modes**: Interactive (full TUI chat), Print (one-shot), RPC (JSON-RPC)
- **Tools**: Read, Write, Edit, EditDiff, Bash, Grep, Ls, Find, Truncate
- **Sessions**: Save/load/list/export/resume with branching
- **Extensions**: Load `.ex` tool files, package manager
- **Infrastructure**: Settings, OAuth, EventBus, Compaction, Telemetry, HTTP Proxy, Migrations, Skills, Harness

## What's Still Missing (vs TypeScript)

### Depth/Polish (not architecture)

1. **~150 more integration tests** — TS has 200+ test files, mostly for edge cases.
2. **OAuth provider-specific implementations** — Anthropic, GitHub Copilot, OpenAI Codex OAuth flows each need specific endpoints/user-agent handling.
3. **Session compaction UI** — The `/compact` slash command exists but not wired into the interactive mode.
4. **Model switching during interactive mode** — Tab cycles models but the `/model <id>` command needs connecting to the actual provider switch.
5. **Startup UI integration** — `StartupUI` module exists but isn't called from `cli.ex` entry point.
6. **Skills system integration** — Skills module loads SKILL.md files but isn't injected into agent prompts.
7. **The remaining 10ish provider variants** — Cloudflare AI Gateway (exists but basic), minimax-cn, moonshotai-cn, xiaomi-token-plan variants, zai-coding-cn, opencode-go. These are thin wrappers (5-10 lines each).
8. **EventBus integration** — Events are emitted but no extensions subscribe yet.
9. **Keybindings in interactive mode** — The TUI Keybindings module exists but the interactive mode uses hardcoded byte checks.
10. **Telemetry in CLI** — Telemetry is collected but not reported at session end.

### Not Yet Built (lower priority)

11. **Lazy provider loading** — TS uses code-split lazy imports for providers. Elixir compiles all modules.
12. **Image processing** — Clipboard image, EXIF orientation, resize (TS has 10+ files for this).
13. **Windows self-update** — Platform-specific installer.
14. **Syntax highlighting** — In TUI markdown code blocks (TS has a dedicated module).
15. **Clipboard integration** — OS clipboard read/write.
16. **Bun-specific features** — TS has bun-specific CLI entry point and Bedrock registration.

## Persistence Enforcer Extension

The `/goal` extension is installed at:
```
/home/maikel/.pi/agent/git/git.maikel.dev/maikelthedev/pi-tools/extensions/persist.ts
```

Use `/goal <description>` to set a goal, `log_evidence` tool to track progress, and `mark_goal_complete` to finish. The extension hooks into turn-end lifecycle to detect premature completion.

## Project Stats Reference

```bash
# Test all apps
nix-shell -p elixir --run "mix test"

# Run a single app's tests
nix-shell -p elixir --run "mix test apps/pi_coding_agent/test/"

# Build escript
cd apps/pi_coding_agent && nix-shell -p elixir --run "MIX_ENV=prod mix escript.build"

# Count modules/lines
find apps -name "*.ex" | wc -l
find apps -name "*.ex" -o -name "*.exs" | xargs wc -l | tail -1

# Git log
git log --oneline
```

## Notes for Continuation

- All tests pass, zero warnings. Start by running `mix test`.
- The interactive mode currently reads raw bytes from stdin in the GenServer. This works but the escape sequence handling could be more robust.
- Provider implementations follow a pattern: each implements `PiAi.Provider` behaviour with `stream_chat/3` and `models/0`. OpenAI-compatible providers delegate to `PiAi.Provider.OpenAICompat`.
- The TDD approach means every new module should have a corresponding test file.
- When adding providers, also add to `PiAi.Providers` list in `apps/pi_ai/lib/pi_ai/providers.ex`.
