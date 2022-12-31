defmodule Core.Context do
  @moduledoc """
  This module allows us to define many different common API endpoints for our resources

  In your context use `resource/3` or `resource/4` to define multiple functions. You
  need to provide a plural of the resource name, the singular of the resource name,
  the schema module, and the module used to randomize the data:

      resource(:florps, :florp, Core.Flans.Florp)

  If you want to define your own version of a function, say create, you need to use the `resource/4`'s 4th argument:

      resource(:florps, :florp, Core.Flan.Florp, [:create])

  Now you can define your own `create_florp()` function.

  The functions that are defined are `:random`, `:list`, `:get`, `:create`, `:delete`, and `:update`.
  """

  @spec resource(atom(), atom(), any, list()) :: any()
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro resource(plural, singular, schema, actions \\ [])
           when is_atom(plural) and is_atom(singular) and is_list(actions) do
    # credo:disable-for-next-line Credo.Check.Refactor.LongQuoteBlocks
    quote do
      import Ecto.Query, only: [from: 2]

      unless Enum.member?(unquote(actions), :count) do
        @doc """
        Counts the number of `#{unquote(schema)}` records in the database.
        """
        @spec unquote(:"count_#{plural}")() :: integer()
        def unquote(:"count_#{plural}")() do
          Core.Repo.aggregate(unquote(schema), :count, :id)
        end
      end

      unless Enum.member?(unquote(actions), :random) do
        @doc """
        Randomly selects a unique `#{unquote(schema)}` record where the primary key arent the ones provided
        """
        @spec unquote(:"random_unique_#{singular}")(list()) :: unquote(schema).t()
        def unquote(:"random_unique_#{singular}")(ids) when is_list(ids) do
          (record in unquote(schema))
          |> from(limit: 1, order_by: fragment("random()"), where: record.id not in ^ids)
          |> Core.Repo.one()
        end

        @doc """
        Randomly selects a `#{unquote(schema)}` record based on a set of conditions
        """
        @spec unquote(:"random_#{singular}")(Keyword.t()) :: unquote(schema).t()
        def unquote(:"random_#{singular}")(where: where) do
          unquote(schema)
          |> from(limit: 1, order_by: fragment("random()"), where: ^where)
          |> Core.Repo.one()
        end

        @doc """
        Randomly selects a `#{unquote(schema)}` record
        """
        @spec unquote(:"random_#{singular}")() :: unquote(schema).t()
        def unquote(:"random_#{singular}")(),
          do: from(unquote(schema), limit: 1, order_by: fragment("random()")) |> Core.Repo.one()
      end

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
      end

      unless Enum.member?(unquote(actions), :update) do
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
