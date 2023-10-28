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

  @doc """
  Returns a new changeset (with no errors) that can be used in frontend forms
  """
  @spec new :: Changeset.t()
  def new do
    %{}
    |> Secret.changeset()
    |> Map.put(:errors, [])
  end

  @doc """
  Encrypts and inserts secret in the store
  """
  @spec encrypt_and_create(map()) :: {:ok, Secret.t()} | {:error, term()}
  def encrypt_and_create(params) do
    params
    |> Secret.changeset()
    |> maybe_encrypt_text()
    |> Repo.insert()
  end

  @spec get(Ecto.UUID.t()) :: Secret.t() | nil
  def get(secret_id) do
    Repo.get(Secret, secret_id)
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
