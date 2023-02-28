defmodule Core.Gameplay.Pack do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "packs" do
    field(:opened, :boolean, default: false)
    belongs_to(:season, Core.Gameplay.Season)
    belongs_to(:account, Core.Users.Account)
    has_many(:pack_slots, Core.Gameplay.PackSlot)
    has_many(:cards, through: [:pack_slots, :card])

    timestamps()
  end

  @type t :: %__MODULE__{
          opened: boolean()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloads = Core.Repo.preload(record, [:season, :account])

    record_with_preloads
    |> Ecto.Changeset.cast(attributes, [:opened])
    |> Ecto.Changeset.put_assoc(:account, attributes[:account] || record_with_preloads.account)
    |> Ecto.Changeset.put_assoc(:season, attributes[:season] || record_with_preloads.season)
    |> Ecto.Changeset.validate_required([:opened, :season])
    |> Ecto.Changeset.foreign_key_constraint(:season_id)
    |> Ecto.Changeset.foreign_key_constraint(:account_id)
  end
end
