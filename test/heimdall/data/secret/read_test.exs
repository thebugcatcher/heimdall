defmodule Heimdall.Data.Secret.ReadTest do
  use Heimdall.DataCase

  alias Heimdall.Data.Secret.Read
  alias Heimdall.Factory

  @required_params ~w[
    ip_address
    read_at
  ]a

  describe "changeset/2" do
    test "returns a valid changeset when valid params are given" do
      {:ok, secret} = Factory.encrypt_and_create()

      params = Factory.valid_secret_read_params(%{secret_id: secret.id})

      changeset = Read.changeset(params)

      assert changeset.valid?
    end

    for required_param <- @required_params do
      test "returns error when #{required_param} isn't present" do
        params =
          Factory.valid_secret_read_params()
          |> Map.put(unquote(required_param), nil)

        changeset = Read.changeset(params)

        refute changeset.valid?
      end
    end
  end
end
