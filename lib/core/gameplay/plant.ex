defmodule Core.Gameplay.Plant do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "plants" do
    field(:name, :string)
    field(:slug, :string)
    field(:rarity, :string)
    has_many(:champions, Core.Gameplay.Champion)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t(),
          rarity: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name, :rarity])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :rarity, :slug])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
