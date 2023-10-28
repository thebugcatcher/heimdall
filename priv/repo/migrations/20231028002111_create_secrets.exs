defmodule Heimdall.Repo.Migrations.CreateSecrets do
  use Ecto.Migration

  def change do
    create table(:secrets, primary_key: false) do
      add(:id, :uuid, primary_key: true)

      add(:title, :string)
      add(:encrypted_text, :text)
      add(:encryption_algo, :string)
      add(:encryption_key, :text)
      add(:expires_at, :utc_datetime)
      add(:max_reads, :integer)
      add(:max_decryption_attempts, :integer)
      add(:attempts, {:array, :map}, default: [])
      add(:reads, {:array, :map}, defaults: [])

      timestamps()
    end

    create(index(:secrets, :title))
  end
end
