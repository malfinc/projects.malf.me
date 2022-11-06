defmodule Core.Context do
  @moduledoc """
  This module allows us to define many different common API endpoints for our resources

  In your context use `resource/4` or `resource/5` to define multiple functions. You
  need to provide a plural of the resource name, the singular of the resource name,
  the schema module, and the module used to randomize the data:

      resource(:florps, :florp, Core.Flans.Florp, Randomizer.Florp)

  If you want to define your own version of a function, say create, you need to use the `resource/5`'s 5th argument:

      resource(:florps, :florp, Core.Flan.Florp, Randomizer.Florp, [:create])

  Now you can define your own `create_florp()` function.

  The functions that are defined are `:random`, `:list`, `:get`, `:create`, `:delete`, `:update`, `:generate`.
  """

  @spec resource(atom(), atom(), any, any | :data, list()) :: any()
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro resource(plural, singular, schema, randomizer, actions \\ [])
           when is_atom(plural) and is_atom(singular) and is_list(actions) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      import Ecto.Query, only: [from: 2]

      unless Enum.member?(unquote(actions), :list) do
        @doc """
        Returns all `#{unquote(schema)}` records sorted by the given order, see Ecto's `Ecto.Query.API.order_by/1` for more details
        """
        @spec unquote(:"list_#{plural}")(Keyword.t()) :: list(unquote(schema).t())
        def unquote(:"list_#{plural}")(order),
          do: from(unquote(schema), order_by: ^order) |> Core.Repo.all()

        @doc """
        Returns all `#{unquote(schema)}` records, unsorted
        """
        @spec unquote(:"list_#{plural}")() :: list(unquote(schema).t())
        def unquote(:"list_#{plural}")(), do: unquote(schema) |> Core.Repo.all()
      end

      unless Enum.member?(unquote(actions), :get) do
        @doc """
        Returns a singular `#{unquote(schema)}`, but if it isn't found will raise an exception
        """
        @spec unquote(:"get_#{singular}!")(String.t()) :: unquote(schema).t()
        def unquote(:"get_#{singular}!")(id) when is_binary(id),
          do: unquote(schema) |> Core.Repo.get!(id)

        @doc """
        Returns a singular `#{unquote(schema)}` and if no record is found it returns `nil`
        """
        @spec unquote(:"get_#{singular}")(String.t()) :: unquote(schema).t() | nil
        def unquote(:"get_#{singular}")(id) when is_binary(id),
          do: unquote(schema) |> Core.Repo.get(id)
      end

      unless Enum.member?(unquote(actions), :create) do
        if unquote(randomizer) == :data do
          @doc """
          Creates a blank `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.changeset/2`, and then inserts it into the database.

          This function will raise an exception if any validation issues are encountered.
          """
          @spec unquote(:"create_#{singular}!")(map()) :: unquote(schema).t()
          def unquote(:"create_#{singular}!")(attributes \\ %{}) when is_map(attributes),
            do: %unquote(schema){} |> unquote(schema).changeset(attributes) |> Core.Repo.insert!()

          @doc """
          Creates a blank `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.changeset/2`, and then inserts it into the database.
          """
          @spec unquote(:"create_#{singular}")(map()) ::
                  {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
          def unquote(:"create_#{singular}")(attributes \\ %{}) when is_map(attributes),
            do: %unquote(schema){} |> unquote(schema).changeset(attributes) |> Core.Repo.insert()
        else
          @doc """
          Creates a blank `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.create_changeset/2`, and then inserts it into the database.

          This function will raise an exception if any validation issues are encountered.
          """
          @spec unquote(:"create_#{singular}!")(map()) :: unquote(schema).t()
          def unquote(:"create_#{singular}!")(attributes \\ %{}) when is_map(attributes),
            do:
              %unquote(schema){} |> unquote(:"new_#{singular}")(attributes) |> Core.Repo.insert!()

          @doc """
          Creates a blank `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.create_changeset/2` and then inserts it into the database.
          """
          @spec unquote(:"create_#{singular}")(map()) ::
                  {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
          def unquote(:"create_#{singular}")(attributes \\ %{}) when is_map(attributes),
            do:
              %unquote(schema){} |> unquote(:"new_#{singular}")(attributes) |> Core.Repo.insert()
        end
      end

      unless Enum.member?(unquote(actions), :update) do
        if unquote(randomizer) == :data do
          @doc """
          Updates a given `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.changeset/2`, and then updates the database.
          """
          @spec unquote(:"update_#{singular}")(unquote(schema).t(), map()) ::
                  {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
          def unquote(:"update_#{singular}")(record, attributes)
              when is_struct(record, unquote(schema)) and is_map(attributes),
              do: unquote(schema).changeset(record, attributes) |> Core.Repo.update()

          @doc """
          Updates a given `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.changeset/2`, and then updates the database.

          This function will raise an exception if any validation issues are encountered.
          """
          @spec unquote(:"update_#{singular}!")(unquote(schema).t(), map()) :: unquote(schema).t()
          def unquote(:"update_#{singular}!")(record, attributes)
              when is_struct(record, unquote(schema)) and is_map(attributes),
              do: unquote(schema).changeset(record, attributes) |> Core.Repo.update!()
        else
          @doc """
          Updates a given `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.update_changeset/2`, and then updates the database.
          """
          @spec unquote(:"update_#{singular}")(unquote(schema).t(), map()) ::
                  {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
          def unquote(:"update_#{singular}")(record, attributes)
              when is_struct(record, unquote(schema)) and is_map(attributes),
              do: record |> unquote(:"change_#{singular}")(attributes) |> Core.Repo.update()

          @doc """
          Updates a given `#{unquote(schema)}`, applies the given `attributes` via
          `#{unquote(schema)}.update_changeset/2`, and then updates the database.

          This function will raise an exception if any validation issues are encountered.
          """
          @spec unquote(:"update_#{singular}!")(unquote(schema).t(), map()) :: unquote(schema).t()
          def unquote(:"update_#{singular}!")(record, attributes)
              when is_struct(record, unquote(schema)) and is_map(attributes),
              do: record |> unquote(:"change_#{singular}")(attributes) |> Core.Repo.update!()
        end
      end

      unless unquote(randomizer) == :data do
        unless Enum.member?(unquote(actions), :new) do
          @doc """
          Takes an empty `#{unquote(schema)}` and applies `attributes` to it via `#{unquote(schema)}.create_changeset/2`
          """
          @spec unquote(:"new_#{singular}")(struct(), map()) ::
                  Ecto.Changeset.t(unquote(schema).t())
          def unquote(:"new_#{singular}")(record, attributes)
              when is_struct(record, unquote(schema)) and is_map(attributes),
              do: unquote(schema).create_changeset(record, attributes)
        end

        unless Enum.member?(unquote(actions), :change) do
          @doc """
          Takes an existing `#{unquote(schema)}` and applies `attributes` to it via `#{unquote(schema)}.update_changeset/2`.
          """
          @spec unquote(:"change_#{singular}")(unquote(schema).t(), map()) ::
                  Ecto.Changeset.t(unquote(schema).t())
          def unquote(:"change_#{singular}")(record, attributes)
              when is_struct(record, unquote(schema)) and is_map(attributes),
              do: unquote(schema).update_changeset(record, attributes)
        end
      end

      unless Enum.member?(unquote(actions), :delete) do
        @doc """
        Takes an existing `#{unquote(schema)}` and deletes it from the database.
        """
        @spec unquote(:"delete_#{singular}")(unquote(schema).t()) ::
                {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
        def unquote(:"delete_#{singular}")(record) when is_struct(record, unquote(schema)),
          do: record |> Core.Repo.delete()

        @doc """
        Takes an existing `#{unquote(schema)}` and deletes it from the database.

        If the row can't be found or constraints prevent you from deleting the row, this will raise an exception.
        """
        @spec unquote(:"delete_#{singular}!")(unquote(schema).t()) :: unquote(schema).t()
        def unquote(:"delete_#{singular}!")(record) when is_struct(record, unquote(schema)),
          do: record |> Core.Repo.delete!()
      end
    end
  end
end
