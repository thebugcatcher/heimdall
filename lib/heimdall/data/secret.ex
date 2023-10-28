defmodule Heimdall.Data.Secret do
  @moduledoc """
  Represents a secret at the application level
  """

  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @timestamps_opts [type: :utc_datetime]

  @valid_encryption_algo ~w[
    aes_gcm
    plaintext
    rsa
  ]a

  @type t :: %__MODULE__{}
  @type algo :: :aes_gcm | :plaintext | :rsa

  schema "secrets" do
    field(:title, :string)
    field(:encrypted_text, :string)
    field(:encryption_algo, Ecto.Enum, values: @valid_encryption_algo)
    field(:encryption_key, :string)
    field(:expires_at, :utc_datetime)
    field(:max_reads, :integer)
    field(:max_decryption_attempts, :integer)

    # embeds_many(:attempts, Heimdall.Secret.Attempt)
    # embeds_many(:reads, Heimdall.Secret.Read)

    timestamps()
  end

  @doc """
  Validates struct parameters
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, ~w[
      title
      encrypted_text
      encryption_algo
      encryption_key
      expires_at
      max_reads
      max_decryption_attempts
    ]a)
    |> validate_required(~w[
      title
      encrypted_text
      encryption_algo
      encryption_key
      expires_at
    ]a)
  end
end
