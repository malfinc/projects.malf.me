defmodule Utilities.Seeder do
  @moduledoc false
  require Logger

  @file_to_module_mapping Map.new([
                            {"gender_identity_options", Core.Data.GenderIdentityOption},
                            {"gender_presentation_options", Core.Data.GenderPresentationOption},
                            {"culture_gender_preference_options",
                             Core.Data.CulturalGenderPreferenceOption},
                            {"cultural_phase_options", Core.Data.CulturalPhaseOption},
                            {"cultural_scale_options", Core.Data.CulturalScaleOption},
                            {"cultural_society_options", Core.Data.CulturalSocietyOption},
                            {"cultural_pillar_options", Core.Data.CulturalPillarOption},
                            {"encounter_context_options", Core.Data.EncounterContextOption},
                            {"group_age_options", Core.Data.GroupAgeOption},
                            {"group_goal_options", Core.Data.GroupGoalOption},
                            {"group_scope_options", Core.Data.GroupScopeOption},
                            {"group_size_options", Core.Data.GroupSizeOption},
                            {"location_development_options", Core.Data.LocationDevelopmentOption},
                            {"location_embellishment_options",
                             Core.Data.LocationEmbellishmentOption},
                            {"location_founding_options", Core.Data.LocationFoundingOption},
                            {"person_appearance_options", Core.Data.PersonAppearanceOption},
                            {"race_options", Core.Data.RaceOption},
                            {"person_role_options", Core.Data.PersonRoleOption},
                            {"person_type_options", Core.Data.PersonTypeOption},
                            {"religion_value_options", Core.Data.ReligionValueOption},
                            {"room_detail_options", Core.Data.RoomDetailOption},
                            {"archetype_options", Core.Data.ArchetypeOption},
                            {"objective_options", Core.Data.ObjectiveOption},
                            {"cultural_art_options", Core.Data.CulturalArtOption},
                            {"cultural_ethos_options", Core.Data.CulturalEthosOption},
                            {"monsters", Core.Data.Monster},
                            {"trap_bait_options", Core.Data.TrapBaitOption},
                            {"trap_effect_options", Core.Data.TrapEffectOption},
                            {"trap_lethality_options", Core.Data.TrapLethalityOption},
                            {"trap_location_options", Core.Data.TrapLocationOption},
                            {"trap_purpose_options", Core.Data.TrapPurposeOption},
                            {"trap_reset_options", Core.Data.TrapResetOption},
                            {"trap_trigger_options", Core.Data.TrapTriggerOption},
                            {"trap_type_options", Core.Data.TrapTypeOption},
                            {"background_options", Core.Data.BackgroundOption},
                            {"asset_options", Core.Data.AssetOption},
                            {"trait_options", Core.Data.TraitOption},
                            {"name_options", Core.Data.NameOption},
                            {"word_options", Core.Data.WordOption}
                          ])

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

  def change(raws, Core.Data.CulturalPillarOption = schema) do
    Enum.map(
      raws,
      &schema.changeset(
        struct(schema),
        Map.merge(
          &1,
          %{
            "name" => String.split(&1["name"], "|"),
            "description" => String.split(&1["description"], "|")
          }
        )
      )
    )
  end

  def change(raws, schema) do
    Enum.map(raws, &schema.changeset(struct(schema), &1))
  end

  def filter(changesets) do
    Enum.each(changesets, fn
      %{valid?: false} = changeset ->
        changeset |> Utilities.Ecto.Changeset.terminal_error_formatting() |> Logger.error()

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
