defmodule Core.Content.Nomination do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "nominations" do
    field(:name, :string)
    field(:state, :string, default: "nominated")
    field(:box_art_url, :string)
    field(:external_game_id, :string)
    belongs_to(:hall, Core.Content.Hall)
    belongs_to(:account, Core.Users.Account)
    has_many(:primary_votes, Core.Content.Vote, foreign_key: :primary_nomination_id)
    has_many(:secondary_votes, Core.Content.Vote, foreign_key: :secondary_nomination_id)
    has_many(:tertiary_votes, Core.Content.Vote, foreign_key: :tertiary_nomination_id)

    timestamps()
  end

  @type t() :: %__MODULE__{}

  @doc false
  def changeset(nomination, attrs) do
    nomination = nomination
    |> Core.Repo.preload([:hall, :account])

    nomination
    |> Ecto.Changeset.cast(attrs, [:name, :external_game_id, :box_art_url])
    |> Ecto.Changeset.put_assoc(:hall, attrs[:hall] || nomination.hall)
    |> Ecto.Changeset.put_assoc(:account, attrs[:account] || nomination.account)
    |> Ecto.Changeset.validate_required([:name, :state, :external_game_id, :box_art_url, :hall, :account])
    |> Ecto.Changeset.foreign_key_constraint(:hall_id)
    |> Ecto.Changeset.foreign_key_constraint(:account_id)
    |> Ecto.Changeset.unique_constraint([:external_game_id, :hall_id])
    |> Ecto.Changeset.unique_constraint([:hall_id, :account_id])
  end
end
