defmodule Heimdall.Secrets do
  @moduledoc """
  Provides an interface to deal with secrets in Heimdall
  """

  alias Ecto.Changeset
  alias Heimdall.Data.Secret
  alias Heimdall.EncryptionAlgo.AesGcm
  alias Heimdall.EncryptionAlgo.Plaintext
  alias Heimdall.EncryptionAlgo.RSA
  alias Heimdall.Repo

  @spec encrypt_and_create(map()) :: {:ok, Secret.t()} | {:error, term()}
  def encrypt_and_create(params) do
    params
    |> Secret.changeset()
    |> maybe_encrypt_text()
    |> Repo.insert()
  end

  defp maybe_encrypt_text(%Changeset{valid?: false} = changeset), do: changeset

  defp maybe_encrypt_text(changeset) do
    secret = Changeset.apply_changes(changeset)

    algo = secret.encryption_algo
    raw = secret.encrypted_text
    key = secret.encryption_key

    encrypted_text = encrypted_text(algo, raw, key)

    Changeset.change(changeset, encrypted_text: encrypted_text)
  end

  defp encrypted_text(:plaintext, raw, key), do: Plaintext.encrypt(raw, key)

  defp encrypted_text(:aes_gcm, raw, key), do: AesGcm.encrypt(raw, key)

  defp encrypted_text(:rsa, raw, key), do: RSA.encrypt(raw, key)
end
