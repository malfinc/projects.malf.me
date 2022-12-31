defmodule Core.Gameplay.Season do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "seasons" do
    field(:position, :float)
    has_many(:seasonal_statistics, Core.Gameplay.SeasonalStatistic)
    has_many(:plants, through: [:seasonal_statistics, :plant])

    timestamps()
  end

  @type t :: %__MODULE__{
          position: float()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:position])
    |> Ecto.Changeset.validate_required([:position])
    |> Ecto.Changeset.unique_constraint(:position)
  end
end
