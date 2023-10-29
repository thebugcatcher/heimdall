defmodule Heimdall.EncryptionAlgo.Plaintext do
  @moduledoc """
  Module corresponding to Plaintext encryption, i.e. no encryption
  """

  @behaviour Heimdall.EncryptionAlgo

  @application_key "120n08ga0sd12e21asd"

  alias Heimdall.EncryptionAlgo.AesGcm

  @doc """
  Simply returns raw text
  """
  @impl true
  def encrypt(raw, _key), do: AesGcm.encrypt(raw, @application_key)

  @doc """
  Simply returns raw text
  """
  @impl true
  def decrypt(raw, _key), do: AesGcm.decrypt(raw, @application_key)
end
