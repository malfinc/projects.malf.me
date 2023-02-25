defmodule Core.Gameplay.Card do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "cards" do
    belongs_to(:season, Core.Gameplay.Season)
    belongs_to(:rarity, Core.Gameplay.Rarity)
    belongs_to(:champion, Core.Gameplay.Champion)

    timestamps()
  end

  @type t :: %__MODULE__{
  }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload = record
    |> Core.Repo.preload([:season, :champion, :rarity])

    record_with_preload
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.put_assoc(:season, attributes[:season] || record_with_preload.season)
    |> Ecto.Changeset.put_assoc(:champion, attributes[:champion] || record_with_preload.champion)
    |> Ecto.Changeset.put_assoc(:rarity, attributes[:rarity] || record_with_preload.rarity)
    |> Ecto.Changeset.validate_required([:champion])
    |> Ecto.Changeset.foreign_key_constraint(:champion_id)
    |> Ecto.Changeset.validate_required([:rarity])
    |> Ecto.Changeset.foreign_key_constraint(:rarity_id)
    |> Ecto.Changeset.validate_required([:season])
    |> Ecto.Changeset.foreign_key_constraint(:season_id)
  end
end
