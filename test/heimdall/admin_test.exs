defmodule Heimdall.AdminTest do
  use Heimdall.DataCase

  alias Heimdall.Admin
  alias Heimdall.Factory

  describe "stats/0" do
    test "returns number of secrets" do
      {:ok, _secret} = Factory.encrypt_and_create()

      stats = Admin.stats()

      assert stats[:secrets_count] == 1

      assert stats[:last_pruned] == "N/A"
    end
  end
end
