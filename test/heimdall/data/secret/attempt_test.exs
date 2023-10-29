defmodule Heimdall.Data.Secret.AttemptTest do
  use Heimdall.DataCase

  alias Heimdall.Data.Secret.Attempt
  alias Heimdall.Factory

  @required_params ~w[
    secret_id
    ip_address
    attempted_at
  ]a

  describe "changeset/2" do
    test "returns a valid changeset when valid params are given" do
      {:ok, secret} = Factory.encrypt_and_create()

      params = Factory.valid_secret_attempt_params(%{secret_id: secret.id})

      changeset = Attempt.changeset(params)

      assert changeset.valid?
    end

    for required_param <- @required_params do
      test "returns error when #{required_param} isn't present" do
        params =
          Factory.valid_secret_attempt_params()
          |> Map.put(unquote(required_param), nil)

        changeset = Attempt.changeset(params)

        refute changeset.valid?
      end
    end
  end
end
