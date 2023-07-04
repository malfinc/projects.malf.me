defmodule Core.Content.Vote do
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "votes" do
    field(:tier, :string)
    belongs_to(:nomination, Core.Content.Nomination)
    belongs_to(:account, Core.Users.Account)

    timestamps()
  end

  @doc false
  def changeset(vote, attrs) do
    vote
    |> Ecto.Changeset.cast(attrs, [:tier])
    |> Ecto.Changeset.validate_required([:tier])
  end
end
