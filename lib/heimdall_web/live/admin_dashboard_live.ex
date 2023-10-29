defmodule HeimdallWeb.AdminDashboardLive do
  use HeimdallWeb, :live_view

  alias Heimdall.Admin

  @default_update_frequency 1_000

  def mount(_params, _session, socket) do
    stats = Admin.stats()

    socket =
      socket
      |> assign(:stats, stats)
      |> assign(:update_frequency, @default_update_frequency)

    schedule_update(socket)

    {:ok, socket}
  end

  def handle_info(:update_stats, socket) do
    stats = Admin.stats()

    socket = assign(socket, :stats, stats)

    schedule_update(socket)

    {:noreply, socket}
  end

  def handle_event(
        "change_update_frequency",
        %{"update_frequency" => update_frequency},
        socket
      ) do
    update_frequency = String.to_integer(update_frequency)

    socket = assign(socket, :update_frequency, update_frequency)

    {:noreply, socket}
  end

  defp schedule_update(socket) do
    update_frequency = socket.assigns[:update_frequency]

    Process.send_after(self(), :update_stats, update_frequency)
  end

  defp update_frequencies do
    [
      {"1 second", 1_000},
      {"5 seconds", 5_000},
      {"10 seconds", 10_000},
      {"30 seconds", 30_000}
    ]
  end
end
