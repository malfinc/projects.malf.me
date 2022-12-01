defmodule Utilities.String do
  @moduledoc """
  Extra functionality relating to strings
  """

  @race_to_collective_mapping %{
    "human" => "human",
    "elf" => "elven",
    "dwarf" => "dwarven",
    "goblin" => "goblin",
    "orc" => "orcish",
    "gnome" => "gnomen",
    "halfling" => "halfling",
    "dragonborn" => "dragonborn",
    "hobgoblin" => "hobgoblin",
    "kobold" => "kobold"
  }

  @doc """
  calculate n-gram distance between two lists or strings

  ## Examples:
      iex> Utilities.String.calculate("lorem ipsum", "lorem dolor", 1)
      0.5454545454545454
      iex> Utilities.String.calculate("lorem", "merol", 2)
      0.0
      iex> Utilities.String.calculate("lorem", "lorem", 2)
      1.0
      iex> Utilities.String.calculate("lorem", "merol", 1)
      1.0
      iex> Utilities.String.calculate("lorem", "xcvbn", 1)
      0.0
  """
  @spec calculate(String.t(), String.t(), integer() | nil) :: float()
  def calculate(a, b, size)
      when (is_integer(size) and size == 0) or
             ((is_binary(a) and byte_size(a) < size) or (is_binary(b) and byte_size(b) < size)),
      do: 0.0

  def calculate(a, b, _) when is_binary(a) and is_binary(b) and a == b, do: 1.0

  def calculate(a, b, size) when is_integer(size) and is_binary(a) and is_binary(b) do
    na = letter_ngrams(a, size)
    nb = letter_ngrams(b, size)
    (Utilities.Ngram.intersect(na, nb) |> length) / max(length(na), length(nb))
  end

  @doc """
  Returns a list of letter N-grams from the given `string`.
  ## Example
      iex> Utilities.String.letter_ngrams("¥ · € · $ · s", 3)
      ["¥ ·", " · ", "· €", " € ", "€ ·", " · $", "· $ ", " $ ·", " · ", "· s"]
      iex> Utilities.String.letter_ngrams("", 2)
      []
      iex> Utilities.String.letter_ngrams("abcd", 1)
      ["a", "b", "c", "d"]
      iex> Utilities.String.letter_ngrams("abcde", 2)
      ["ab", "bc", "cd", "de"]
  """
  @spec letter_ngrams(String.t(), non_neg_integer) :: list
  def letter_ngrams(string, 1) do
    special_graphemes(string)
  end

  def letter_ngrams(string, n) when is_integer(n) and n > 1 do
    graphemes = string |> special_graphemes()

    do_letter_ngrams(n, length(graphemes), graphemes)
  end

  defp do_letter_ngrams(n, len, graphemes) when len >= n do
    [
      Enum.take(graphemes, n) |> IO.iodata_to_binary()
      | do_letter_ngrams(n, len - 1, tl(graphemes))
    ]
  end

  defp do_letter_ngrams(_, _, _) do
    []
  end

  defp special_graphemes(text) do
    text
    |> String.graphemes()
    |> Enum.reduce([], fn
      character, [] ->
        [character]

      character, ["^"] ->
        ["^#{character}"]

      "$", list ->
        Enum.slice(list, 0..-2) |> List.insert_at(-1, "#{Enum.at(list, -1)}$")

      character, list ->
        list |> List.insert_at(-1, character)
    end)
  end

  def as_slug(text) do
    text |> String.replace(~r/\s/, "_")
  end

  def titlecase(input) do
    input
    |> String.capitalize()
    |> String.split()
    |> Enum.map_join(" ", fn string ->
      cond do
        String.match?(string, ~r/^(and|the|with|in|is|a|an|of)$/) ->
          string

        String.match?(string, ~r/-/) ->
          string |> String.split("-") |> Enum.map_join("-", &String.capitalize/1)

        String.match?(string, ~r/'\w{2,}/) ->
          string |> String.split("'") |> Enum.map_join("'", &String.capitalize/1)

        true ->
          string |> String.capitalize()
      end
    end)
  end

  def pronoun(target) do
    cond do
      Map.has_key?(target, :gender_presentation) -> target.gender_presentation
      target.__struct__ == Core.Universes.Person -> "them"
    end
  end

  @spec gendered_noun(String.t(), String.t()) :: String.t()
  def gendered_noun(word, "feminine"), do: "#{word}ess"
  def gendered_noun(word, "masculine"), do: word
  def gendered_noun(word, _), do: word

  @spec collective_for(String.t()) :: String.t()
  def collective_for(race) when is_binary(race) do
    @race_to_collective_mapping[race]
  end
end
