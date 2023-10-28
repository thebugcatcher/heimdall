defmodule Heimdall.EncryptionAlgo do
  @moduledoc """
  This module defines behavior needed to be followed by an encryption algo to
  work with Heimdall
  """

  @callback encrypt(String.t(), String.t()) :: String.t()

  @callback decrypt(String.t(), String.t()) :: String.t()
end
