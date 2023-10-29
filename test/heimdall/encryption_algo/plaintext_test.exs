defmodule Heimdall.EncryptionAlgo.PlaintextTest do
  use ExUnit.Case

  alias Heimdall.EncryptionAlgo.Plaintext

  describe "encrypt/2" do
    test "even plaintext algo stores encrypted at rest" do
      raw = "somesupersecretpassword"
      key = "somekey"

      encrypted = Plaintext.encrypt(raw, key)

      assert encrypted != raw
    end
  end

  describe "decrypt/2" do
    test "returns the raw text" do
      raw = "somesupersecretpassword"
      key = "somekey"

      encrypted = Plaintext.encrypt(raw, key)

      decrypted = Plaintext.decrypt(encrypted, key)

      assert decrypted == raw
    end
  end
end
