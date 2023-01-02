defmodule Core.Gameplay.Season do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "seasons" do
    field(:position, :integer)
    has_many(:challenges, Core.Gameplay.Challenge)

    timestamps()
  end

  @type t :: %__MODULE__{
          position: float()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.validate_required([])
  end
end
