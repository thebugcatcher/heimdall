defmodule Heimdall.EncryptionAlgo.AesGcm do
  @moduledoc """
  Module corresponding to AES GCM encryption
  """

  @behaviour Heimdall.EncryptionAlgo

  @doc """
  Simply returns raw text
  """
  @impl true
  def encrypt(raw, key) do
    secret_key = prepare_key(key)

    initialization_vector = :crypto.strong_rand_bytes(16)

    {ciphertext, ciphertag} =
      :crypto.crypto_one_time_aead(
        :aes_gcm,
        secret_key,
        initialization_vector,
        raw,
        "",
        16,
        true
      )

    :base64.encode(initialization_vector <> ciphertag <> ciphertext)
  end

  @doc """
  Simply returns raw text
  """
  @impl true
  def decrypt(encrypted, key) do
    secret_key = prepare_key(key)

    <<initialization_vector::binary-16, ciphertag::binary-16, ciphertext::binary>> =
      :base64.decode(encrypted)

    :crypto.crypto_one_time_aead(
      :aes_gcm,
      secret_key,
      initialization_vector,
      ciphertext,
      "",
      ciphertag,
      false
    )
  end

  defp prepare_key(key), do: :crypto.hash(:md5, key)
end
