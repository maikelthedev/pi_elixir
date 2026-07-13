defmodule PiCodingAgent.Core.PackageManager do
  @moduledoc "Package manager detection and interaction."
  def detect(dir \\ ".") do
    cond do
      File.exists?(Path.join(dir, "mix.exs")) -> {:ok, :mix}
      File.exists?(Path.join(dir, "package.json")) -> {:ok, :npm}
      File.exists?(Path.join(dir, "Cargo.toml")) -> {:ok, :cargo}
      File.exists?(Path.join(dir, "go.mod")) -> {:ok, :go}
      File.exists?(Path.join(dir, "pyproject.toml")) -> {:ok, :uv}
      File.exists?(Path.join(dir, "requirements.txt")) -> {:ok, :pip}
      File.exists?(Path.join(dir, "Gemfile")) -> {:ok, :bundler}
      File.exists?(Path.join(dir, "build.gradle")) -> {:ok, :gradle}
      File.exists?(Path.join(dir, "pom.xml")) -> {:ok, :maven}
      true -> {:error, :not_found}
    end
  end

  def install_cmd(:mix), do: "mix deps.get"
  def install_cmd(:npm), do: "npm install"
  def install_cmd(:cargo), do: "cargo build"
  def install_cmd(:go), do: "go mod download"
  def install_cmd(:uv), do: "uv sync"
  def install_cmd(:pip), do: "pip install -r requirements.txt"
  def install_cmd(:bundler), do: "bundle install"
  def install_cmd(:gradle), do: "gradle build"
  def install_cmd(:maven), do: "mvn install"

  def test_cmd(:mix), do: "mix test"
  def test_cmd(:npm), do: "npm test"
  def test_cmd(:cargo), do: "cargo test"
  def test_cmd(:go), do: "go test ./..."
  def test_cmd(:uv), do: "uv run pytest"
  def test_cmd(:pip), do: "pytest"
  def test_cmd(:bundler), do: "bundle exec rspec"
  def test_cmd(:gradle), do: "gradle test"
  def test_cmd(:maven), do: "mvn test"

  def build_cmd(:mix), do: "mix compile"
  def build_cmd(:npm), do: "npm run build"
  def build_cmd(:cargo), do: "cargo build --release"
  def build_cmd(:go), do: "go build ./..."
  def build_cmd(:uv), do: "uv run python -m build"
  def build_cmd(:pip), do: "python -m build"
  def build_cmd(:bundler), do: "bundle exec rake build"
  def build_cmd(:gradle), do: "gradle assemble"
  def build_cmd(:maven), do: "mvn package"

  def name(:mix), do: "Mix (Elixir)"
  def name(:npm), do: "npm (Node.js)"
  def name(:cargo), do: "Cargo (Rust)"
  def name(:go), do: "Go modules"
  def name(:uv), do: "uv (Python)"
  def name(:pip), do: "pip (Python)"
  def name(:bundler), do: "Bundler (Ruby)"
  def name(:gradle), do: "Gradle (Java)"
  def name(:maven), do: "Maven (Java)"
end
