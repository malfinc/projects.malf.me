defmodule Core.Gameplay.Challenge do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "challenges" do
    belongs_to(:season, Core.Gameplay.Season)
    many_to_many(:champions, Core.Gameplay.Champion, join_through: "challenge_champions")

    timestamps()
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Core.Repo.preload([:season])
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.validate_required([:season])
  end
end
