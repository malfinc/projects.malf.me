defmodule Core.Gameplay.Pack do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "packs" do
    field(:opened, :boolean, default: false)
    belongs_to(:season, Core.Gameplay.Season)
    has_many(:pack_slots, Core.Gameplay.PackSlot)

    timestamps()
  end

  @type t :: %__MODULE__{
    opened: boolean()
  }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Core.Repo.preload([:season])
    |> Ecto.Changeset.cast(attributes, [:opened])
    |> Ecto.Changeset.put_assoc(:season, attributes[:season])
    |> Ecto.Changeset.validate_required([:opened, :season])
    |> Ecto.Changeset.foreign_key_constraint(:season_id)
  end
end
