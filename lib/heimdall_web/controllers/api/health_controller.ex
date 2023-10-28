defmodule HeimdallWeb.API.HealthController do
  use HeimdallWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(200)
    |> json(%{status: "ok"})
  end
end
