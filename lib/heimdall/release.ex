defmodule Heimdall.Release do
  @moduledoc """
  This module is used for release tasks like running migrations
  """

  @app :heimdall

  @doc """
  Runs migrations for all repos in heimdall app
  """
  @spec migrate :: :ok
  def migrate do
    Application.ensure_all_started(:ssl)

    load_app()

    for repo <- repos() do
      {:ok, _, _} =
        Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :up, all: true))
    end

    :ok
  end

  @doc """
  Rolls back migrations for a given repo
  """
  @spec rollback(module(), any()) :: :ok
  def rollback(repo, version) do
    load_app()

    {:ok, _, _} =
      Ecto.Migrator.with_repo(repo, &Ecto.Migrator.run(&1, :down, to: version))

    :ok
  end

  defp repos do
    Application.fetch_env!(@app, :ecto_repos)
  end

  defp load_app do
    Application.load(@app)
  end
end
