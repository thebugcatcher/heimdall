defmodule Heimdall.EncryptionAlgo.Plaintext do
  @moduledoc """
  Module corresponding to Plaintext encryption, i.e. no encryption
  """

  @behaviour Heimdall.EncryptionAlgo

  @doc """
  Simply returns raw text
  """
  @impl true
  def encrypt(raw, _key), do: raw

  @doc """
  Simply returns raw text
  """
  @impl true
  def decrypt(raw, _key), do: raw
end
