defmodule HeimdallWeb.Admin.DashboardController do
  use HeimdallWeb, :controller

  alias Heimdall.Admin

  def index(conn, params) do
    stats = Admin.stats(params)
    render(conn, :index, stats: stats)
  end
end
