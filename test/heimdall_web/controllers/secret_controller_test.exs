defmodule HeimdallWeb.SecretControllerTest do
  use HeimdallWeb.ConnCase

  alias Heimdall.Factory

  describe "new/2 (GET /)" do
    test "renders new page with a form", %{conn: conn} do
      conn = get(conn, ~p"/")

      assert html_response(conn, 200) =~ "Title"
    end
  end

  describe "create/2 (POST /secrets)" do
    test "encrypts and creates a secret if valid params", %{conn: conn} do
      params = Factory.valid_secret_params()

      conn = post(conn, ~p"/secrets", %{secret: params})

      assert Phoenix.Flash.get(conn.assigns.flash, :info) ==
               "Secret successfully created"
    end

    test "is unsuccessful if invalid params", %{conn: conn} do
      params = Factory.valid_secret_params(%{encrypted_text: nil})

      conn = post(conn, ~p"/secrets", %{secret: params})

      assert html_response(conn, 200) =~ "be blank"
    end
  end

  describe "successfully_created/2 (GET /successfully_created)" do
    test "renders a page with the link to given secret", %{conn: conn} do
      {:ok, secret} = Factory.encrypt_and_create()

      conn = get(conn, ~p"/successfully_created?secret_id=#{secret.id}")

      assert html_response(conn, 200) =~ url(~p"/secrets/#{secret.id}")
    end

    test "renders 404 when secret with id doesn't exist", %{conn: conn} do
      secret_id = Ecto.UUID.generate()

      conn = get(conn, ~p"/successfully_created?secret_id=#{secret_id}")

      assert html_response(conn, 302) =~ "secret_404"
    end
  end

  describe "show/2 (GET /secrets/:secret_id)" do
    test "renders a page with the given secret when exists", %{conn: conn} do
      {:ok, secret} = Factory.encrypt_and_create()

      conn = get(conn, ~p"/secrets/#{secret.id}")

      assert html_response(conn, 200) =~ secret.title
    end

    test "renders 404 when secret with id doesn't exist", %{conn: conn} do
      secret_id = Ecto.UUID.generate()

      conn = get(conn, ~p"/secrets/#{secret_id}")

      assert html_response(conn, 302) =~ "secret_404"
    end
  end

  describe "secret_404/2 (GET /secret_404)" do
    test "renders a page with expected content", %{conn: conn} do
      conn = get(conn, ~p"/secret_404")

      assert html_response(conn, 200) =~ "Secret doesn't exist"
    end
  end
end
