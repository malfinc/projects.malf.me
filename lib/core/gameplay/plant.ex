defmodule Core.Gameplay.Plant do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plants" do
    field(:name, :string)
    field(:slug, :string)
    field(:species, :string)
    field(:image_uri, :string)
    field(:rarity_symbol, :string)

    field(:starting_attributes, :map,
      default: %{
        strength: 1,
        speed: 1,
        intelligence: 1,
        endurance: 1,
        luck: 1
      }
    )

    many_to_many(:seasons, Core.Gameplay.Season, join_through: "season_plants", unique: true)
    has_many(:champions, Core.Gameplay.Champion)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t(),
          species: String.t(),
          image_uri: String.t(),
          rarity_symbol: String.t(),
          starting_attributes: map()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [
      :name,
      :species,
      :image_uri,
      :rarity_symbol,
      :starting_attributes
    ])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([
      :name,
      :slug,
      :species,
      :image_uri,
      :rarity_symbol,
      :starting_attributes
    ])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
