defmodule Heimdall.EncryptionAlgo.RSA do
  @moduledoc """
  Module corresponding to RSA encryption
  """

  @behaviour Heimdall.EncryptionAlgo

  @doc """
  Returns text encrypted using RSA algo
  """
  @impl true
  def encrypt(raw, public_key_pem) do
    raw
    |> :public_key.encrypt_public(key_from_pem(public_key_pem))
    |> Base.encode16()
  end

  @doc """
  Returns decrypted text using RSA algo
  """
  @impl true
  def decrypt(encrypted, private_key_pem) do
    encrypted
    |> Base.decode16!()
    |> :public_key.decrypt_private(key_from_pem(private_key_pem))
  end

  defp key_from_pem(pem) do
    [rsa_entry] = :public_key.pem_decode(pem)
    :public_key.pem_entry_decode(rsa_entry)
  end
end
