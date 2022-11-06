defmodule CoreWeb.Live.LiveHelpers do
  @moduledoc false

  def timestamp_in_words_ago(%{updated_at: updated_at}) do
    Timex.from_now(updated_at)
  end

  def timestamp_in_words_ago(%{inserted_at: inserted_at}) do
    Timex.from_now(inserted_at)
  end

  def code_as_html(source) do
    inspect(source, pretty: true, limit: :infinity)
    |> (&"```\n#{&1}\n```").()
    |> Earmark.as_html!()
    |> Phoenix.HTML.raw()
  end

  def error_at_ago(%{"at" => at}) do
    at
    |> DateTime.from_iso8601()
    |> case do
      {:ok, datetime, _} -> Timex.from_now(datetime)
      {:error, _} -> at
    end
  end
end
