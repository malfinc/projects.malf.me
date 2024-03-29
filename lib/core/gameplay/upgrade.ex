defmodule Core.Gameplay.Upgrade do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "upgrades" do
    field(:stage, :integer)
    field(:strength, :integer)
    field(:speed, :integer)
    field(:intelligence, :integer)
    field(:endurance, :integer)
    field(:luck, :integer)
    belongs_to(:champion, Core.Gameplay.Champion)
    belongs_to(:patron_account, Core.Users.Account)

    timestamps()
  end

  @type t :: %__MODULE__{
          stage: integer(),
          strength: integer(),
          speed: integer(),
          intelligence: integer(),
          endurance: integer(),
          luck: integer()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload = Core.Repo.preload(record, [:champion])

    record
    |> Ecto.Changeset.cast(attributes, [
      :stage,
      :strength,
      :speed,
      :intelligence,
      :endurance,
      :luck
    ])
    |> Ecto.Changeset.put_assoc(:champion, attributes[:champion] || record_with_preload.champion)
    |> Ecto.Changeset.validate_required([
      :stage,
      :strength,
      :speed,
      :intelligence,
      :endurance,
      :luck,
      :champion
    ])
    |> Ecto.Changeset.foreign_key_constraint(:champion_id)
  end
end
