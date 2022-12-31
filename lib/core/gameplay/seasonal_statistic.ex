defmodule Core.Gameplay.SeasonalStatistic do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "seasonal_statistics" do
    field(:wins, :integer)
    field(:losses, :integer)
    belongs_to(:champion, Core.Gameplay.Champion)
    belongs_to(:season, Core.Gameplay.Season)
    has_many(:upgrades, Core.Gameplay.Upgrade)

    timestamps()
  end

  @type t :: %__MODULE__{
          wins: float(),
          losses: float()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:wins, :losses])
    |> Ecto.Changeset.put_assoc(:champion, attributes.champion)
    |> Ecto.Changeset.put_assoc(:season, attributes.season)
    |> Ecto.Changeset.validate_required([:wins, :losses])
    |> Ecto.Changeset.foreign_key_constraint(:champion_id)
    |> Ecto.Changeset.foreign_key_constraint(:season_id)
    |> Ecto.Changeset.unique_constraint([:champion_id, :season_id])
  end
end
