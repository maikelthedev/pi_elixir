defmodule PiAgent.Harness.Session do
  @moduledoc "Session storage implementations for the agent harness."
  defstruct [:repo, :session_id, :entries]

  @type t :: %__MODULE__{repo: atom(), session_id: String.t(), entries: [map()]}

  def new(opts \\ []) do
    repo = Keyword.get(opts, :repo, PiAgent.Harness.Session.MemoryRepo)
    %__MODULE__{repo: repo, session_id: Keyword.get(opts, :session_id, generate_id()), entries: []}
  end

  def add_entry(%__MODULE__{entries: e} = s, entry) do
    entry = Map.put(entry, :timestamp, DateTime.utc_now() |> DateTime.to_unix())
    %{s | entries: e ++ [entry]}
  end

  def save(%__MODULE__{repo: repo, session_id: sid, entries: entries}) do
    repo.save(sid, entries)
  end

  def load(%__MODULE__{repo: repo, session_id: sid}) do
    repo.load(sid)
  end

  defp generate_id, do: "sess_#{:erlang.unique_integer([:positive])}"
end
