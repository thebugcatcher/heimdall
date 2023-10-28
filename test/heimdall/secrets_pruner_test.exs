defmodule Heimdall.SecretsPrunerTest do
  use Heimdall.DataCase

  alias Heimdall.Factory
  alias Heimdall.Secrets
  alias Heimdall.SecretsPruner

  describe "application start up" do
    test "pruner process should be running" do
      assert Process.whereis(SecretsPruner)
    end
  end

  describe "handle_info/2 (:prune)" do
    test "prunes old secrets successfully" do
      {:ok, old_secret} =
        Factory.encrypt_and_create(%{
          expires_at: DateTime.add(DateTime.utc_now(), -10, :second)
        })

      assert Secrets.get(old_secret.id)

      pid = Process.whereis(SecretsPruner)

      Process.send(pid, :prune, [])

      :timer.sleep(1_000)

      refute Secrets.get(old_secret.id)
    end

    test "doesn't prune new secrets" do
      {:ok, new_secret} =
        Factory.encrypt_and_create(%{
          expires_at: DateTime.add(DateTime.utc_now(), 10, :second)
        })

      assert Secrets.get(new_secret.id)

      pid = Process.whereis(SecretsPruner)

      Process.send(pid, :prune, [])

      :timer.sleep(1_000)

      assert Secrets.get(new_secret.id)
    end
  end
end
