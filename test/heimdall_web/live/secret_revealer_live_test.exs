defmodule HeimdallWeb.SecretRevealerLiveTest do
  use HeimdallWeb.ConnCase
  import Phoenix.LiveViewTest

  alias Heimdall.Factory
  alias Heimdall.Repo
  alias HeimdallWeb.SecretRevealerLive

  describe "mount/3" do
    test "shows a secret's parameters along with a form", %{conn: conn} do
      raw = "supersecretpassword"
      key = "key"

      {:ok, secret} =
        Factory.encrypt_and_create(%{
          encryption_key: key,
          encrypted_text: raw
        })

      {:ok, _view, html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id}
        )

      assert html =~ secret.title
    end
  end

  describe "handle_event/3 (decrypt)" do
    test "reveals secret if correct key is given", %{conn: conn} do
      raw = "supersecretpassword"
      key = "key"

      {:ok, secret} =
        Factory.encrypt_and_create(%{
          encryption_key: key,
          encrypted_text: raw
        })

      {:ok, view, html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id}
        )

      # Secret isn't visible until form is submitted
      refute html =~ raw

      # Secret is visible after the form is submitted
      assert view
             |> element("form")
             |> render_submit(%{"key" => key}) =~ raw
    end

    test "doesn't reveal secret if bad key is given", %{conn: conn} do
      raw = "supersecretpassword"
      key = "key"

      {:ok, secret} =
        Factory.encrypt_and_create(%{
          encryption_key: key,
          encrypted_text: raw
        })

      {:ok, view, html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id}
        )

      # Secret isn't visible until form is submitted
      refute html =~ raw

      # Secret isn't visible if bad key is given
      refute view
             |> element("form")
             |> render_submit(%{"key" => "bad_key"}) =~ raw

      # Decryption failed message is shown
      assert view
             |> element("form")
             |> render_submit(%{"key" => "bad_key"}) =~ "Error in decryption"
    end
  end

  describe "handle_info/3 (check_expiration)" do
    test "redirects if secret is expired", %{conn: conn} do
      raw = "supersecretpassword"
      key = "key"

      {:ok, secret} =
        Factory.encrypt_and_create(%{
          encryption_key: key,
          encrypted_text: raw,
          expires_at: DateTime.add(DateTime.utc_now(), 2, :second)
        })

      {:ok, view, _html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id}
        )

      html =
        view
        |> element("form")
        |> render_submit(%{"key" => key})

      # Doesn't say secret is expired
      refute html =~ "Secret Expired"

      # Wait for enough time for the secret to expire
      :timer.sleep(5_000)

      # Live redirect
      refute Process.alive?(view.pid)
    end

    test "redirects if secret is deleted", %{conn: conn} do
      raw = "supersecretpassword"
      key = "key"

      {:ok, secret} =
        Factory.encrypt_and_create(%{
          encryption_key: key,
          encrypted_text: raw
        })

      {:ok, view, _html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id}
        )

      html =
        view
        |> element("form")
        |> render_submit(%{"key" => key})

      # Doesn't say secret is expired
      refute html =~ "Secret Expired"

      Repo.delete(secret)

      # Wait for enough time for the secret to expire
      :timer.sleep(2_000)

      # Live redirect
      refute Process.alive?(view.pid)
    end

    test "doesn't redirect if secret isn't expired", %{conn: conn} do
      raw = "supersecretpassword"
      key = "key"

      {:ok, secret} =
        Factory.encrypt_and_create(%{
          encryption_key: key,
          encrypted_text: raw
        })

      {:ok, view, _html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id}
        )

      html =
        view
        |> element("form")
        |> render_submit(%{"key" => key})

      # Doesn't say secret is expired
      refute html =~ "Secret Expired"

      :timer.sleep(1_000)

      updated_html = render(view)

      refute updated_html =~ "Secret Expired"
    end
  end
end
