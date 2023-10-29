defmodule HeimdallWeb.SecretRevealerLiveTest do
  use HeimdallWeb.ConnCase
  import Phoenix.LiveViewTest

  alias Heimdall.Data.Secret.Read
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
          session: %{"secret_id" => secret.id, "ip" => "ip"}
        )

      assert html =~ secret.title
    end

    test "doesn't show secret parameters if wrong ip", %{conn: conn} do
      {:ok, secret} =
        Factory.encrypt_and_create(%{
          ip_regex: "bad_regex"
        })

      {:ok, _view, html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id, "ip" => "ip"}
        )

      refute html =~ secret.title
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
          session: %{"secret_id" => secret.id, "ip" => "ip"}
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
          session: %{"secret_id" => secret.id, "ip" => "ip"}
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

    test "doesn't show secret parameters if wrong ip", %{conn: conn} do
      {:ok, secret} =
        Factory.encrypt_and_create(%{
          ip_regex: "bad_regex"
        })

      {:ok, view, _html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id, "ip" => "ip"}
        )

      # Secret isn't visible if bad ip is given
      refute view
             |> has_element?("form")
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
          session: %{"secret_id" => secret.id, "ip" => "ip"}
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
          session: %{"secret_id" => secret.id, "ip" => "ip"}
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

    test "redirects if secret is not expired but stale", %{conn: conn} do
      raw = "supersecretpassword"
      key = "key"

      {:ok, secret} =
        Factory.encrypt_and_create(%{
          encryption_key: key,
          encrypted_text: raw,
          expires_at: DateTime.add(DateTime.utc_now(), 2, :second),
          max_reads: 1
        })

      {:ok, view, _html} =
        live_isolated(
          conn,
          SecretRevealerLive,
          session: %{"secret_id" => secret.id, "ip" => "ip"}
        )

      %{secret_id: secret.id}
      |> Factory.valid_secret_read_params()
      |> Read.changeset()
      |> Repo.insert()

      view
      |> element("form")
      |> render_submit(%{"key" => key})

      # Wait for enough time for the secret to expire
      :timer.sleep(5_000)

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
          session: %{"secret_id" => secret.id, "ip" => "ip"}
        )

      view
      |> element("form")
      |> render_submit(%{"key" => key})

      :timer.sleep(5_000)

      # No Live redirect
      assert Process.alive?(view.pid)
    end
  end
end
