defmodule Utilities.Ecto.Changeset do
  @moduledoc """
  Extra functionality relating to changesets
  """

  @spec put_assoc(Ecto.Changeset.t(), atom(), any(), maybe: true) :: Ecto.Changeset.t()
  def put_assoc(changeset, key, value, maybe: true) do
    if value do
      Ecto.Changeset.put_assoc(changeset, key, value, [])
    else
      changeset
    end
  end
end
