defmodule Heimdall.EncryptionAlgo.AesGcmTest do
  use ExUnit.Case

  alias Heimdall.EncryptionAlgo.AesGcm

  describe "encrypt/2" do
    test "successfully encrypts raw text with using the given key" do
      raw = "somesupersecretpassword"
      key = "somekey"

      encrypted = AesGcm.encrypt(raw, key)

      refute encrypted == raw
    end

    test "successfully encrypts raw text when key is 1 letter" do
      raw = "somesupersecretpassword"
      key = "s"

      encrypted = AesGcm.encrypt(raw, key)

      refute encrypted == raw
    end

    test "successfully encrypts raw text when key is empty" do
      raw = "somesupersecretpassword"
      key = ""

      encrypted = AesGcm.encrypt(raw, key)

      refute encrypted == raw
    end

    test "raises error when key is nil" do
      raw = "somesupersecretpassword"
      key = nil

      assert_raise(ArgumentError, fn ->
        AesGcm.encrypt(raw, key)
      end)
    end

    test "raises error when key is an integer" do
      raw = "somesupersecretpassword"
      key = 1234

      assert_raise(ArgumentError, fn ->
        AesGcm.encrypt(raw, key)
      end)
    end
  end

  describe "decrypt/2" do
    test "successfully decrypts if using the correct key" do
      raw = "somesupersecretpassword"
      key = "somekey"

      encrypted = AesGcm.encrypt(raw, key)

      decrypted = AesGcm.decrypt(encrypted, key)

      assert decrypted == raw
    end

    test "successfully decrypts if using the correct key (1 letter)" do
      raw = "somesupersecretpassword"
      key = "1"

      encrypted = AesGcm.encrypt(raw, key)

      decrypted = AesGcm.decrypt(encrypted, key)

      assert decrypted == raw
    end

    test "successfully decrypts if using the correct key (empty string)" do
      raw = "somesupersecretpassword"
      key = ""

      encrypted = AesGcm.encrypt(raw, key)

      decrypted = AesGcm.decrypt(encrypted, key)

      assert decrypted == raw
    end

    test "returns :error when using the wrong key" do
      raw = "somesupersecretpassword"
      key = "somekey"

      encrypted = AesGcm.encrypt(raw, key)

      bad_key = "bad_key"

      assert AesGcm.decrypt(encrypted, bad_key) == :error
    end
  end
end
