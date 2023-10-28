defmodule HeimdallWeb.RouterTest do
  use HeimdallWeb.ConnCase

  test "live_dashboard /dev/dashboard", %{conn: conn} do
    conn = get(conn, ~p"/dev/dashboard")
    assert html_response(conn, 302) =~ "/dashboard/home"
  end
end
