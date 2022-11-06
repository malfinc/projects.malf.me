defmodule Utilities.Seeder do
  @moduledoc false
  require Logger

  @file_to_module_mapping Map.new([])

  def load_all(), do: @file_to_module_mapping |> Map.keys() |> Enum.each(&load/1)

  def load(slug, force \\ true) do
    Logger.debug("Starting load for #{slug}...")

    if force do
      clean(@file_to_module_mapping[slug])
    end

    read(slug)
    |> change(@file_to_module_mapping[slug])
    |> filter()
    |> prepare(@file_to_module_mapping[slug])
    |> write(@file_to_module_mapping[slug])
  end

  def clean(schema) do
    Logger.debug("Deleting #{schema} records...")
    Core.Repo.delete_all(schema)
  end

  def change(raws, schema) do
    Enum.map(raws, &schema.changeset(struct(schema), &1))
  end

  def filter(changesets) do
    Enum.each(changesets, fn
      %{valid?: false} = changeset ->
        changeset |> Core.Repo.terminal_error_formatting() |> Logger.error()

      otherwise ->
        otherwise
    end)

    Logger.debug("Filtering out bad data...")
    Enum.filter(changesets, fn %{valid?: validity} -> validity end)
  end

  def read(slug) do
    Application.app_dir(:core, "priv/data/#{slug}.bin")
    |> tap(fn path -> Logger.debug("Reading #{path}...") end)
    |> File.read()
    |> tap(fn _ -> Logger.debug("Parsing...") end)
    |> case do
      {:ok, content} ->
        :erlang.binary_to_term(content)

      otherwise ->
        otherwise
    end
    |> case do
      {:ok, data} -> data
      otherwise -> otherwise
    end
    |> tap(fn
      {:error, error} -> Logger.error(error)
      _ -> Logger.debug("Parsing finished!")
    end)
  end

  def prepare(changesets, schema) do
    Logger.debug("Preparing changesets...")

    Enum.map(changesets, fn changeset ->
      Ecto.Changeset.apply_changes(changeset)
      |> Map.put(:inserted_at, Utilities.Time.now())
      |> Map.put(:updated_at, Utilities.Time.now())
      |> Map.put(:id, changeset.changes[:id] || Ecto.UUID.generate())
      |> Map.take(schema.__schema__(:fields))
    end)
  end

  def write(maps, schema) do
    Logger.debug("Writing chunks of 10k...")

    maps
    |> Enum.chunk_every(10_000)
    |> Enum.flat_map(fn chunk ->
      Logger.debug("Writing chunk of #{length(chunk)}...")

      {count, ids} =
        Core.Repo.insert_all(
          schema,
          chunk,
          returning: [:id]
        )

      Logger.debug("Finished writing #{count} records!")
      ids
    end)
  end
end
