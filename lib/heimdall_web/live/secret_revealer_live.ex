defmodule HeimdallWeb.SecretRevealerLive do
  use HeimdallWeb, :live_view

  alias Heimdall.Secrets

  def mount(_params, %{"secret_id" => secret_id}, socket) do
    secret = Heimdall.Secrets.get(secret_id)

    socket =
      socket
      |> assign(:secret, secret)
      |> assign(:decrypted_text, nil)
      |> assign(:decryption_error, nil)

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
          |> assign(:decryption_error, nil)

        {:noreply, socket}

      {:error, error} ->
        socket =
          socket
          |> put_flash(:error, "Error in decryption")
          |> assign(:decrypted_text, nil)
          |> assign(:decryption_error, error)

        {:noreply, socket}
    end
  end
end
