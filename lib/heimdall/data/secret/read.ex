defmodule Heimdall.Data.Secret.Read do
  @moduledoc """
  Represents a secret read at the application level
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias Heimdall.Data.Secret

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  @timestamps_opts [type: :utc_datetime]

  @type t :: %__MODULE__{}

  schema "reads" do
    field(:ip_address, :string)
    field(:read_at, :utc_datetime)

    belongs_to(:secret, Secret)

    timestamps()
  end

  @doc """
  Validates struct parameters
  """
  @spec changeset(t(), map()) :: Ecto.Changeset.t()
  def changeset(struct \\ %__MODULE__{}, params) do
    struct
    |> cast(params, ~w[
      secret_id
      ip_address
      read_at
    ]a)
    |> validate_required(~w[
      secret_id
      ip_address
      read_at
    ]a)
  end
end
