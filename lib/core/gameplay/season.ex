defmodule Core.Gameplay.Season do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "seasons" do
    field(:position, :integer)
    has_many(:challenges, Core.Gameplay.Challenge)
    many_to_many(:plants, Core.Gameplay.Plant, join_through: "season_plants", unique: true)

    timestamps()
  end

  @type t :: %__MODULE__{
          position: float()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload = Core.Repo.preload(record, [:plants])

    record_with_preload
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.put_assoc(:plants, attributes[:plants])
    |> Ecto.Changeset.validate_required([:plants])
  end
end
