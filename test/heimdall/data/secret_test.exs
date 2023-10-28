defmodule Heimdall.Data.SecretTest do
  use Heimdall.DataCase

  alias Heimdall.Data.Secret
  alias Heimdall.Factory

  @required_params ~w[
    title
    encrypted_text
    encryption_algo
    encryption_key
    expires_at
  ]a

  describe "changeset/2" do
    test "returns a valid changeset when valid params are given" do
      params = Factory.valid_secret_params()

      changeset = Secret.changeset(params)

      assert changeset.valid?
    end

    for required_param <- @required_params do
      test "returns error when #{required_param} isn't present" do
        params =
          Factory.valid_secret_params()
          |> Map.put(unquote(required_param), nil)

        changeset = Secret.changeset(params)

        refute changeset.valid?
      end
    end
  end
end
