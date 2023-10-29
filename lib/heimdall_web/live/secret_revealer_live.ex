defmodule HeimdallWeb.SecretRevealerLive do
  use HeimdallWeb, :live_view

  alias Heimdall.Secrets

  def mount(_params, %{"secret_id" => secret_id, "ip" => ip}, socket) do
    secret = Heimdall.Secrets.get(secret_id)

    socket =
      socket
      |> assign(:secret, secret)
      |> assign(:decrypted_text, nil)
      |> assign(:redirect, false)
      |> assign(:ip, ip)

    if secret_viewable?(secret, socket) do
      schedule_expiration_check()

      {
        :ok,
        assign(socket, :secret, secret)
      }
    else
      socket = assign(socket, :redirect, true)

      Process.send_after(self(), :check_expiration, 1000)

      {:ok, socket}
    end
  end

  def handle_event("decrypt", %{"key" => key}, socket) do
    secret = socket.assigns[:secret]

    if secret_viewable?(secret, socket) do
      do_decrypt(secret, socket, key)
    else
      {
        :noreply,
        socket |> redirect(to: ~p"/secret_404")
      }
    end
  end

  def handle_info(:check_expiration, socket) do
    secret = socket.assigns[:secret]
    redirect = socket.assigns[:redirect]

    if !redirect and Secrets.not_expired?(secret) do
      schedule_expiration_check()

      {:noreply, socket}
    else
      {
        :noreply,
        socket |> redirect(to: ~p"/secret_404")
      }
    end
  end

  defp do_decrypt(secret, socket, key) do
    ip = socket.assigns[:ip]

    case Secrets.decrypt(secret, key) do
      {:ok, decrypted_text} ->
        socket =
          socket
          |> put_flash(:info, "Successfully decrypted")
          |> assign(:decrypted_text, decrypted_text)

        Secrets.create_secret_read(secret, ip, DateTime.utc_now())

        schedule_expiration_check()

        {:noreply, socket}

      {:error, error} ->
        socket =
          socket
          |> put_flash(:error, "Error in decryption:\n #{error}")
          |> assign(:decrypted_text, nil)

        Secrets.create_secret_attempt(secret, ip, DateTime.utc_now())

        {:noreply, socket}
    end
  end

  defp secret_viewable?(secret, socket) do
    ip = socket.assigns[:ip]

    Secrets.not_expired?(secret) and Secrets.not_stale?(secret) and
      Secrets.ip_allowed?(secret, ip)
  end

  defp schedule_expiration_check do
    Process.send_after(
      self(),
      :check_expiration,
      expiration_check_period_ms()
    )
  end

  defp expiration_check_period_ms do
    Application.get_env(:heimdall, :secret_expiration_check_period_ms, 1_500)
  end
end
