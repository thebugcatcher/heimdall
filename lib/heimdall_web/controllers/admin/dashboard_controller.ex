defmodule HeimdallWeb.Admin.DashboardController do
  use HeimdallWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
