defmodule Core.Content.Vote do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "votes" do
    field(:tier, :string)
    belongs_to(:primary_nomination, Core.Content.Nomination)
    belongs_to(:secondary_nomination, Core.Content.Nomination)
    belongs_to(:tertiary_nomination, Core.Content.Nomination)
    belongs_to(:account, Core.Users.Account)

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> Ecto.Changeset.cast(attrs, [:tier])
    |> Ecto.Changeset.put_assoc(:primary_nomination, attrs[:primary_nomination] || vote.primary_nomination)
    |> Ecto.Changeset.put_assoc(:secondary_nomination, attrs[:secondary_nomination] || vote.secondary_nomination)
    |> Ecto.Changeset.put_assoc(:tertiary_nomination, attrs[:tertiary_nomination] || vote.tertiary_nomination)
    |> Ecto.Changeset.validate_required([:tier, :primary_nomination, :secondary_nomination, :tertiary_nomination])
  end
end
