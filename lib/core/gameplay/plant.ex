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
    field(:starting_attributes, :map, default: %{
      strength: 1,
      speed: 1,
      intelligence: 1,
      endurance: 1,
      luck: 1
    })
    has_many(:champions, Core.Gameplay.Champion)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t(),
          species: String.t(),
          image_uri: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name, :species, :image_uri])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug, :species, :image_uri])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
