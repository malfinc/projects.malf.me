defmodule Core.Gameplay.PackSlot do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pack_slots" do
    field(:flipped, :boolean, default: false)
    belongs_to(:pack, Core.Gameplay.Pack)
    belongs_to(:champion, Core.Gameplay.Champion)

    timestamps()
  end

  @type t :: %__MODULE__{
    flipped: boolean()
  }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Core.Repo.preload([:pack, :champion])
    |> Ecto.Changeset.cast(attributes, [:flipped])
    |> Ecto.Changeset.put_assoc(:pack, attributes[:pack])
    |> Ecto.Changeset.put_assoc(:champion, attributes[:champion])
    |> Ecto.Changeset.validate_required([:flipped, :pack, :champion])
    |> Ecto.Changeset.foreign_key_constraint(:pack_id)
    |> Ecto.Changeset.foreign_key_constraint(:champion_id)
  end
end
