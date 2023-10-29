defmodule HeimdallWeb.AdminDashboardLiveTest do
  use HeimdallWeb.ConnCase
  import Phoenix.LiveViewTest

  alias Heimdall.Factory
  alias HeimdallWeb.AdminDashboardLive

  describe "mount/3" do
    test "shows admin stats", %{conn: conn} do
      {:ok, secret} = Factory.encrypt_and_create()

      {:ok, _view, html} =
        live_isolated(
          conn,
          AdminDashboardLive
        )

      assert html =~ secret.title

      assert html =~ "Secrets Count"

      assert html =~ "1"
    end
  end

  describe "handle_event/3 (change_update_frequency)" do
    test "updates change frequency", %{conn: conn} do
      {:ok, view, html} =
        live_isolated(
          conn,
          AdminDashboardLive
        )

      assert html =~ "1 second"

      # Secret is visible after the form is submitted
      assert view
             |> element("form")
             |> render_change(%{"update_frequency" => "5000"}) =~ "5 seconds"
    end
  end

  describe "handle_info/3 (update_stats)" do
    test "updates stats", %{conn: conn} do
      {:ok, secret} = Factory.encrypt_and_create()

      {:ok, view, html} =
        live_isolated(
          conn,
          AdminDashboardLive
        )

      assert html =~ secret.title

      assert html =~ "Secrets Count"

      assert html =~ "1"

      # Wait for enough time for the secret to expire
      :timer.sleep(2_000)

      assert render(view) =~ "2"
    end
  end
end
