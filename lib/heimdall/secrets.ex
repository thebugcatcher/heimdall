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

  import Ecto.Query

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

  @doc """
  TODO
  """
  @spec decrypt(Secret.t(), String.t()) :: {:ok, String.t()} | {:error, term()}
  def decrypt(secret, decryption_key) do
    algo = secret.encryption_algo
    encrypted = secret.encrypted_text

    try do
      case decrypted_text(algo, encrypted, decryption_key) do
        :error -> {:error, "Error in decryption"}
        text -> {:ok, text}
      end
    rescue
      _e -> {:error, "Error in decryption"}
    end
  end

  @doc """
  TODO
  """
  @spec get(Ecto.UUID.t()) :: Secret.t() | nil
  def get(secret_id) do
    Repo.get(Secret, secret_id)
  end

  @doc """
  TODO
  """
  @spec not_expired?(Secret.t()) :: boolean()
  def not_expired?(%Secret{id: secret_id}) do
    Secret
    |> where([s], s.id == ^secret_id and s.expires_at > ^DateTime.utc_now())
    |> Repo.one()
    |> is_nil()
    |> Kernel.not()
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

  defp decrypted_text(:plaintext, enc, key), do: Plaintext.decrypt(enc, key)

  defp decrypted_text(:aes_gcm, enc, key), do: AesGcm.decrypt(enc, key)

  defp decrypted_text(:rsa, enc, key), do: RSA.decrypt(enc, key)
end
