defmodule Heimdall.SecretsTest do
  use Heimdall.DataCase

  alias Heimdall.Factory
  alias Heimdall.Secrets

  @public_key_pem File.read!("./test/support/keys/example-public-key.pem")

  describe "encrypt_and_create/1" do
    test "successfully encrypts and inserts a secret (for aes_gcm)" do
      raw = "supersecretpassword"

      params =
        Factory.valid_secret_params(%{
          encrypted_text: raw,
          encryption_algo: :aes_gcm
        })

      assert params[:encrypted_text] == raw

      {:ok, secret} = Secrets.encrypt_and_create(params)

      refute secret.encrypted_text == raw
    end

    test "successfully encrypts and inserts a secret (for plaintext)" do
      raw = "supersecretpassword"

      params =
        Factory.valid_secret_params(%{
          encrypted_text: raw,
          encryption_algo: :plaintext
        })

      assert params[:encrypted_text] == raw

      {:ok, secret} = Secrets.encrypt_and_create(params)

      assert secret.encrypted_text == raw
    end

    test "successfully encrypts and inserts a secret (for rsa)" do
      raw = "supersecretpassword"

      params =
        Factory.valid_secret_params(%{
          encrypted_text: raw,
          encryption_algo: :rsa,
          encryption_key: @public_key_pem
        })

      assert params[:encrypted_text] == raw

      {:ok, secret} = Secrets.encrypt_and_create(params)

      assert secret.encrypted_text != raw
    end

    test "doesn't encrypt text if invalid params" do
      raw = nil

      params =
        Factory.valid_secret_params(%{
          encrypted_text: raw,
          encryption_algo: :aes_gcm
        })

      {:error, changeset} = Secrets.encrypt_and_create(params)

      refute changeset.valid?
    end
  end
end
