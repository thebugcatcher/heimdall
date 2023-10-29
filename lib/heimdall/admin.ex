defmodule Heimdall.Admin do
  @moduledoc """
  Admin-related tasks
  """

  import Ecto.Query

  alias Heimdall.Data.Secret
  alias Heimdall.Repo
  alias Heimdall.SecretsPruner

  @doc """
  Returns Heimdall stats using given parameters
  """
  @spec stats() :: map()
  def stats do
    %{
      secrets_count: secrets_count(),
      last_pruned: last_pruned(),
      secrets: secrets()
    }
  end

  defp secrets_count do
    Secret
    |> select([s], count(s.id))
    |> Repo.one()
  end

  defp last_pruned do
    pid = Process.whereis(SecretsPruner)

    cond do
      is_nil(pid) ->
        "N/A"

      pid |> :sys.get_state() |> is_nil() ->
        "N/A"

      datetime = :sys.get_state(pid) ->
        Timex.format!(datetime, "%F @ %T", :strftime)
    end
  end

  defp secrets do
    Secret
    |> order_by([s], desc: s.inserted_at, desc: s.expires_at)
    |> limit(^secrets_limit())
    |> Repo.all()
    |> Repo.preload([:attempts, :reads])
  end

  defp secrets_limit do
    Application.get_env(:heimdall, :admin_secrets_show_limit, 100)
  end
end
