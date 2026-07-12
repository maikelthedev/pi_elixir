defmodule PiCodingAgent.MixProject do
  use Mix.Project

  def project do
    [
      app: :pi_coding_agent,
      version: "0.1.0",
      build_path: "../../_build",
      config_path: "../../config/config.exs",
      deps_path: "../../deps",
      lockfile: "../../mix.lock",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:pi_agent, in_umbrella: true},
      {:pi_tui, in_umbrella: true},
      {:pi_ai, in_umbrella: true}
    ]
  end
end
