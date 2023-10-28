defmodule HeimdallWeb.API.HealthControllerTest do
  use HeimdallWeb.ConnCase, async: false

  describe "index/2" do
    test "returns 200", %{conn: conn} do
      path = ~p"/api/health"

      conn = get(conn, path)
      assert conn.status == 200
    end
  end
end
