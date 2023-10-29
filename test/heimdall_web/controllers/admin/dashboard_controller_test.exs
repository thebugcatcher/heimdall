defmodule HeimdallWeb.Admin.DashboardControllerTest do
  use HeimdallWeb.ConnCase

  describe "index/2 (GET /admin)" do
    test "doesn't allow view page without user and password", %{conn: conn} do
      conn = get(conn, ~p"/admin")

      assert conn.status == 401
    end

    test "shows dashboard if authenticated", %{conn: conn} do
      conn = add_admin_auth(conn)

      conn = get(conn, ~p"/admin")

      refute conn.status == 401
    end
  end

  defp add_admin_auth(conn) do
    basic_auth =
      Plug.BasicAuth.encode_basic_auth(
        admin_user(),
        admin_password()
      )

    put_req_header(
      conn,
      "authorization",
      basic_auth
    )
  end

  defp admin_user do
    Application.get_env(:heimdall, :admin_user)
  end

  defp admin_password do
    Application.get_env(:heimdall, :admin_password)
  end
end
