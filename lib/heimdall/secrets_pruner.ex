defmodule Heimdall.SecretsPruner do
  @moduledoc """
  Responsible for deleting expired or max attempted secrets
  """

  use GenServer

  import Ecto.Query

  alias Heimdall.Data.Secret
  alias Heimdall.Repo

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl true
  def init(_) do
    schedule_prune()

    {:ok, nil}
  end

  @impl true
  def handle_info(:prune, _last_ran_at) do
    prune()

    schedule_prune()

    {:noreply, DateTime.utc_now()}
  end

  defp schedule_prune do
    Process.send_after(self(), :prune, time_interval_ms())
  end

  defp prune do
    current_datetime = DateTime.utc_now()

    Secret
    |> where(
      [s],
      s.expires_at < ^current_datetime
    )
    |> Repo.delete_all(timeout: delete_query_timeout())
  end

  defp time_interval_ms, do: Map.get(configuration(), :time_interval_ms)
  defp delete_query_timeout, do: Map.get(configuration(), :delete_query_timeout)

  @default_configuration %{
    time_interval_ms: 30_000,
    delete_query_timeout: 1_500
  }

  defp configuration do
    config =
      :heimdall
      |> Application.get_env(__MODULE__, [])
      |> Enum.into(%{})

    Map.merge(@default_configuration, config)
  end
end
