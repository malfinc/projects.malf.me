defmodule Core.Gameplay.Champion do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "champions" do
    field(:name, :string)
    field(:slug, :string)
    field(:image_uri, :string)
    field(:position, :integer, virtual: true)
    belongs_to(:plant, Core.Gameplay.Plant)
    has_many(:pack_slots, Core.Gameplay.Champion)
    has_many(:upgrades, Core.Gameplay.Upgrade)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t(),
          image_uri: String.t(),
          position: integer()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload = Core.Repo.preload(record, [:plant])

    record_with_preload
    |> Ecto.Changeset.cast(attributes, [:name, :image_uri])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.put_assoc(:plant, attributes[:plant] || record_with_preload.plant)
    |> Ecto.Changeset.validate_required([:name, :slug, :plant])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.foreign_key_constraint(:plant_id)
    |> Ecto.Changeset.unique_constraint(:plant_id)
  end
end
