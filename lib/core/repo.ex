defmodule Core.Repo do
  @moduledoc """
  A set of funcionality that relates to the specific database we use (postgresql).
  """
  use Ecto.Repo,
    otp_app: :core,
    adapter: Ecto.Adapters.Postgres

  require Ecto.Query

  @spec terminal_error_formatting({:error, Ecto.Changeset.t()} | {:ok, any} | Ecto.Changeset.t()) ::
          :ok | String.t()
  def terminal_error_formatting({:ok, _}), do: :ok

  def terminal_error_formatting({:error, changeset}) when is_struct(changeset, Ecto.Changeset),
    do: terminal_error_formatting(changeset)

  def terminal_error_formatting(changeset) when is_struct(changeset, Ecto.Changeset) do
    changeset
    |> traverse_errors()
    |> format_mapping()
    |> prefix_error_with_struct(changeset)
    |> suffix_error_with_changeset(changeset)
  end

  defp traverse_errors(changeset) when is_struct(changeset, Ecto.Changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn
      {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
      msg -> msg
    end)
  end

  defp format_mapping(mapping) do
    mapping
    |> Enum.map(fn
      {field, validation_message} when is_binary(validation_message) ->
        "#{field} #{validation_message}"

      {field, subdetails} when is_map(subdetails) ->
        "#{field} #{format_mapping(subdetails)}"

      {field, list} when is_list(list) ->
        list |> Enum.map(fn detail -> "#{field} #{detail}" end) |> Utilities.List.to_sentence()
    end)
    |> Utilities.List.to_sentence()
  end

  defp prefix_error_with_struct(message, changeset) do
    "#{changeset.data.__struct__} had validation errors:\n\t\t#{message}"
  end

  defp suffix_error_with_changeset(message, changeset) do
    "#{message}\n\t#{changeset.changes |> inspect}"
  end

  @doc """
  Takes a database table name or an `Ecto.Query` partial and either a singular field or many fields to map each returned record to. For example:

      from(Core.Users.Account) |> Core.Repo.pluck([:email_address, :name])

  Would return:

      [["kurtis@malf.me", "Kurtis Rainbolt-Greene"], ["james@malf.me", "James Ryan"]]
  """
  @spec pluck(atom | Ecto.Query.t(), atom | list(atom)) :: list(any)
  def pluck(model_or_query, field)
      when is_atom(model_or_query) or (is_struct(model_or_query) and is_atom(field)) do
    model_or_query
    |> Ecto.Query.select(^[field])
    |> Core.Repo.all()
    |> Utilities.List.pluck(field)
  end

  def pluck(model_or_query, fields)
      when is_atom(model_or_query) or (is_struct(model_or_query) and is_list(fields)) do
    model_or_query
    |> Ecto.Query.select(^fields)
    |> Core.Repo.all()
    |> Enum.map(fn record -> Map.values(Map.take(record, fields)) end)
  end
end
