defmodule Heimdall.EncryptionAlgo.RSATest do
  use ExUnit.Case

  alias Heimdall.EncryptionAlgo.RSA

  @public_key_pem File.read!("./test/support/keys/example-public-key.pem")

  @private_key_pem File.read!("./test/support/keys/example-private-key.pem")

  describe "encrypt/2" do
    test "successfully encrypts raw text with valid RSA public key" do
      raw = "somesupersecretpassword"
      key = @public_key_pem

      encrypted = RSA.encrypt(raw, key)

      refute encrypted == raw
    end

    test "raises error if invalid public key is used" do
      raw = "somesupersecretpassword"
      key = "bad_key"

      assert_raise(MatchError, fn ->
        RSA.encrypt(raw, key)
      end)
    end
  end

  describe "decrypt/2" do
    test "successfully decrypts if using the correct key" do
      raw = "somesupersecretpassword"
      public_key = @public_key_pem
      private_key = @private_key_pem

      encrypted = RSA.encrypt(raw, public_key)

      decrypted = RSA.decrypt(encrypted, private_key)

      assert decrypted == raw
    end

    test "raises error if invalid private key is used" do
      raw = "somesupersecretpassword"
      public_key = @public_key_pem
      private_key = "bad_key"

      encrypted = RSA.encrypt(raw, public_key)

      assert_raise(MatchError, fn ->
        RSA.decrypt(encrypted, private_key)
      end)
    end
  end
end
