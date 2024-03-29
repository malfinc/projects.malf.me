defmodule Core.Gameplay.Weekly do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "weeklies" do
    field(:position, :integer)
    belongs_to(:season, Core.Gameplay.Season)
    has_many(:matches, Core.Gameplay.Match)

    timestamps()
  end

  @type t :: %__MODULE__{
          position: integer()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload =
      record
      |> Core.Repo.preload([:season])

    record_with_preload
    |> Ecto.Changeset.cast(attributes, [:position])
    |> Ecto.Changeset.put_assoc(:season, attributes[:season] || record_with_preload.season)
    |> Ecto.Changeset.validate_required([:season, :position])
    |> Ecto.Changeset.foreign_key_constraint(:season_id)
  end
end
