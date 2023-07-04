defmodule Core.Content.Hall do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "halls" do
    field(:state, :string, default: "nominating")
    field(:category, :string)
    field(:deadline_at, :utc_datetime)
    has_many(:nominations, Core.Content.Nomination)
    has_many(:votes, through: [:nominations, :votes])

    timestamps()
  end

  @doc false
  def changeset(hall, attrs) do
    hall
    |> Ecto.Changeset.cast(attrs, [:deadline_at, :category])
    |> Ecto.Changeset.validate_required([:deadline_at, :category])
  end
end
