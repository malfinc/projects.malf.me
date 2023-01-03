defmodule Core.Gameplay.Champion do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "champions" do
    field(:name, :string)
    field(:slug, :string)
    field(:position, :integer)
    many_to_many(:challenges, Core.Gameplay.Champion, join_through: "challenge_champions")
    belongs_to(:plant, Core.Gameplay.Plant)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: String.t(),
          position: integer(),
          slug: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload = Core.Repo.preload(record, [:plant])
    record_with_preload
    |> Ecto.Changeset.cast(attributes, [:name])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.put_assoc(:plant, attributes[:plant] || record_with_preload.plant)
    |> Ecto.Changeset.validate_required([:name, :slug, :plant])
    |> Ecto.Changeset.unique_constraint(:name)
  end
end
