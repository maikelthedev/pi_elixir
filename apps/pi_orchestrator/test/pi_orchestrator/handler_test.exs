defmodule PiOrchestrator.ConfigTest do
  use ExUnit.Case, async: true
  alias PiOrchestrator.Config
  test "from_env returns defaults" do
    config = Config.from_env()
    assert config.port == 4000
    assert config.host == "0.0.0.0"
    assert config.max_sessions == 100
  end
  test "merge with map" do
    config = Config.from_env() |> Config.merge(%{port: 8080})
    assert config.port == 8080
  end
end

defmodule PiOrchestrator.HandlerTest do
  use ExUnit.Case, async: false
  setup do
    start_supervised!({PiOrchestrator.SessionSupervisor, name: PiOrchestrator.SessionSupervisor})
    start_supervised!({PiOrchestrator.Handler, name: :test_handler, storage: PiOrchestrator.Storage})
    :ok
  end
  test "status returns ok" do
    {:ok, result} = PiOrchestrator.Handler.handle_request(:test_handler, "status", %{})
    assert result["status"] == "ok"
  end
  test "session list returns empty list" do
    {:ok, result} = PiOrchestrator.Handler.handle_request(:test_handler, "session.list", %{})
    assert is_list(result["sessions"])
  end
  test "unknown method returns error" do
    {:error, msg} = PiOrchestrator.Handler.handle_request(:test_handler, "unknown.method", %{})
    assert msg =~ "Unknown"
  end
end

defmodule PiOrchestrator.RadiusTest do
  use ExUnit.Case, async: true
  test "default allows home dir" do
    r = PiOrchestrator.Radius.default()
    assert PiOrchestrator.Radius.allows?(r, System.user_home())
  end
  test "denies .ssh" do
    r = PiOrchestrator.Radius.default()
    refute PiOrchestrator.Radius.allows?(r, Path.join(System.user_home(), ".ssh/id_rsa"))
  end
  test "for_project allows project dir" do
    r = PiOrchestrator.Radius.for_project("/tmp/project")
    assert PiOrchestrator.Radius.allows?(r, "/tmp/project/lib/main.ex")
  end
  test "allows nil path" do
    r = PiOrchestrator.Radius.default()
    assert PiOrchestrator.Radius.allows?(r, nil)
  end
end

defmodule PiOrchestrator.ServeTest do
  use ExUnit.Case, async: true
  test "plug compiles without errors" do
    assert is_atom(PiOrchestrator.Serve)
  end
end

defmodule PiOrchestrator.SupervisorTest do
  use ExUnit.Case, async: true
  test "config struct has all fields" do
    c = %PiOrchestrator.Config{port: 4000, host: "0.0.0.0"}
    assert c.port == 4000
  end
end
