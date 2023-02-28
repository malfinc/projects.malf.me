defmodule Core.Gameplay.PackSlot do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "pack_slots" do
    belongs_to(:pack, Core.Gameplay.Pack)
    belongs_to(:card, Core.Gameplay.Card)

    timestamps()
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Core.Repo.preload([:pack, :card])
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.put_assoc(:pack, attributes[:pack] || record.pack)
    |> Ecto.Changeset.put_assoc(:card, attributes[:card] || record.card)
    |> Ecto.Changeset.validate_required([:pack, :card])
    |> Ecto.Changeset.foreign_key_constraint(:pack_id)
    |> Ecto.Changeset.foreign_key_constraint(:card_id)
    |> Ecto.Changeset.unique_constraint([:card_id])
  end
end
