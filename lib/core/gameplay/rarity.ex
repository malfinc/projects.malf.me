defmodule Core.Gameplay.Rarity do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rarities" do
    field(:name, :string)
    field(:slug, :string)
    field(:color, :string)
    field(:season_pick_rate, :integer)
    field(:pack_pick_percentage, :float)
    has_many(:cards, Core.Gameplay.Card)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: float(),
          slug: float(),
          color: float(),
          season_pick_rate: integer(),
          pack_pick_percentage: float()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name, :color, :season_pick_rate, :pack_pick_percentage])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug, :color, :season_pick_rate, :pack_pick_percentage])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
