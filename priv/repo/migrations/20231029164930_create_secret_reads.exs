defmodule Heimdall.Repo.Migrations.CreateSecretReads do
  use Ecto.Migration

  def change do
    create table(:reads, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:secret_id, references(:secrets, type: :uuid, on_delete: :delete_all))

      add(:ip_address, :string)
      add(:read_at, :utc_datetime)

      timestamps()
    end
  end
end
