defmodule Core.Content.Hall do
  @moduledoc false
  use Ecto.Schema

  @categories [
    :speed,
    :try,
    :story,
    :hundreds
  ]

  @states [
    :nominating,
    :voting,
    :closed
  ]

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "halls" do
    field(:state, Ecto.Enum, values: @states, default: :nominating)
    field(:category, Ecto.Enum, values: @categories)
    field(:deadline_at, :utc_datetime)
    has_many(:nominations, Core.Content.Nomination)

    timestamps()
  end

  @type t() :: %__MODULE__{}

  @doc false
  def changeset(hall, attrs) do
    hall
    |> Ecto.Changeset.cast(attrs, [:deadline_at, :category])
    |> Ecto.Changeset.validate_required([:deadline_at, :category, :state])
  end
end
