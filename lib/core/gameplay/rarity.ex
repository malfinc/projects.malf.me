defmodule Core.Gameplay.Rarity do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "rarities" do
    field(:name, :string)
    field(:slug, :string)
    field(:color, :string)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: float(),
          slug: float(),
          color: float()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name, :color])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug, :color])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
