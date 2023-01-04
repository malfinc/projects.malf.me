defmodule Core.Gameplay.Match do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "matches" do
    belongs_to(:challenge, Core.Gameplay.Challenge)
    belongs_to(:left_champion, Core.Gameplay.Champion)
    belongs_to(:right_champion, Core.Gameplay.Champion)

    timestamps()
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Core.Repo.preload([:challenge, :left_champion, :right_champion])
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.put_assoc(:left_champion, attributes[:left_champion])
    |> Ecto.Changeset.put_assoc(:right_champion, attributes[:right_champion])
    |> Ecto.Changeset.put_assoc(:challenge, attributes[:challenge])
    |> Ecto.Changeset.validate_required([:challenge, :left_champion, :right_champion])
    |> Ecto.Changeset.foreign_key_constraint(:challenge_id)
    |> Ecto.Changeset.foreign_key_constraint(:left_champion_id)
    |> Ecto.Changeset.foreign_key_constraint(:right_champion_id)
  end
end
