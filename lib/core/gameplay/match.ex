defmodule Core.Gameplay.Match do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "matches" do
    belongs_to(:weekly, Core.Gameplay.Weekly)
    belongs_to(:season, Core.Gameplay.Season)
    belongs_to(:division, Core.Gameplay.Division)
    belongs_to(:left_champion, Core.Gameplay.Champion)
    belongs_to(:right_champion, Core.Gameplay.Champion)

    timestamps()
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload =
      Core.Repo.preload(record, [:season, :division, :weekly, :left_champion, :right_champion])

    record_with_preload
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.put_assoc(
      :left_champion,
      attributes[:left_champion] || record_with_preload.left_champion
    )
    |> Ecto.Changeset.put_assoc(
      :right_champion,
      attributes[:right_champion] || record_with_preload.right_champion
    )
    |> Ecto.Changeset.put_assoc(:season, attributes[:season] || record_with_preload.season)
    |> Ecto.Changeset.put_assoc(:weekly, attributes[:weekly] || record_with_preload.weekly)
    |> Ecto.Changeset.put_assoc(:division, attributes[:division] || record_with_preload.division)
    |> Ecto.Changeset.validate_required([
      :season,
      :division,
      :weekly,
      :left_champion,
      :right_champion
    ])
    |> Ecto.Changeset.foreign_key_constraint(:weekly_id)
    |> Ecto.Changeset.foreign_key_constraint(:season_id)
    |> Ecto.Changeset.foreign_key_constraint(:division_id)
    |> Ecto.Changeset.foreign_key_constraint(:left_champion_id)
    |> Ecto.Changeset.foreign_key_constraint(:right_champion_id)
  end
end
