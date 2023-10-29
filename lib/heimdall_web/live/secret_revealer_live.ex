defmodule HeimdallWeb.SecretRevealerLive do
  use HeimdallWeb, :live_view

  alias Heimdall.Secrets

  def mount(_params, %{"secret_id" => secret_id}, socket) do
    secret = Heimdall.Secrets.get(secret_id)

    socket =
      socket
      |> assign(:secret, secret)
      |> assign(:decrypted_text, nil)

    schedule_expiration_check()

    {
      :ok,
      assign(socket, :secret, secret)
    }
  end

  def handle_event("decrypt", %{"key" => key}, socket) do
    secret = socket.assigns[:secret]

    case Secrets.decrypt(secret, key) do
      {:ok, decrypted_text} ->
        socket =
          socket
          |> put_flash(:info, "Successfully decrypted")
          |> assign(:decrypted_text, decrypted_text)

        schedule_expiration_check()

        {:noreply, socket}

      {:error, error} ->
        socket =
          socket
          |> put_flash(:error, "Error in decryption:\n #{error}")
          |> assign(:decrypted_text, nil)

        {:noreply, socket}
    end
  end

  def handle_info(:check_expiration, socket) do
    secret = socket.assigns[:secret]

    if Secrets.not_expired?(secret) do
      schedule_expiration_check()

      {:noreply, socket}
    else
      {
        :noreply,
        socket |> redirect(to: ~p"/secret_404")
      }
    end
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
