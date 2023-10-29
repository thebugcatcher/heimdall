defmodule Heimdall.Repo.Migrations.CreateSecretAttempts do
  use Ecto.Migration

  def change do
    create table(:attempts, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:secret_id, references(:secrets, type: :uuid))

      add(:ip_address, :string)
      add(:attempted_at, :utc_datetime)

      timestamps()
    end
  end
end
