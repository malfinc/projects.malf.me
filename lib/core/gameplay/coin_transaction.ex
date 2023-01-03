defmodule Core.Gameplay.CoinTransaction do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "coin_transactions" do
    field(:value, :integer, default: 0)
    belongs_to(:account, Core.Users.Account)

    timestamps()
  end

  @type t :: %__MODULE__{
          value: integer()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload = Core.Repo.preload(record, [:account])

    record
    |> Ecto.Changeset.cast(attributes, [:value])
    |> Ecto.Changeset.put_assoc(:account, attributes[:account] || record_with_preload.account)
    |> Ecto.Changeset.validate_required([:value, :account])
    |> Ecto.Changeset.foreign_key_constraint(:account_id)
  end
end
