defmodule Core.Gameplay.Division do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "divisions" do
    field(:name, :string)
    field(:slug, :string)
    belongs_to(:conference, Core.Gameplay.Conference)
    has_many(:matches, Core.Gameplay.Match)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload =
      record
      |> Core.Repo.preload([:conference])

    record_with_preload
    |> Ecto.Changeset.cast(attributes, [:name])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.put_assoc(
      :conference,
      attributes[:conference] || record_with_preload.conference
    )
    |> Ecto.Changeset.validate_required([:name, :slug, :conference])
    |> Ecto.Changeset.foreign_key_constraint(:conference_id)
  end
end
