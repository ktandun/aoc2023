defmodule Day07 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ", trim: true)

      {hand, String.to_integer(bid)}
    end)
  end

  def get_hand_type_strength(hand, :part1) do
    hand_map =
      hand
      |> String.to_charlist()
      |> Enum.reduce(%{}, fn letter, acc ->
        letter_count = Map.get(acc, letter) || 0
        Map.put(acc, letter, letter_count + 1)
      end)

    keys = Map.keys(hand_map)
    values = Map.values(hand_map) |> Enum.sort()

    cond do
      length(keys) == 1 -> 1
      length(keys) == 2 && values == [1, 4] -> 2
      length(keys) == 2 && values == [2, 3] -> 3
      length(keys) == 3 && values == [1, 1, 3] -> 4
      length(keys) == 3 && values == [1, 2, 2] -> 5
      length(keys) == 4 && values == [1, 1, 1, 2] -> 6
      length(keys) == length(values) -> 7
    end
  end

  def get_hand_type_strength(hand, :part2) do
    hand_map =
      hand
      |> String.to_charlist()
      |> Enum.reduce(%{}, fn letter, acc ->
        letter_count = Map.get(acc, letter) || 0
        Map.put(acc, letter, letter_count + 1)
      end)

    # 74 = Joker
    joker_count = Map.get(hand_map, 74, 0)
    has_joker = joker_count > 0
    only_joker_hand = joker_count == 5

    distinct_cards_count =
      if has_joker,
        do: length(Map.keys(hand_map)) - 1,
        else: length(Map.keys(hand_map))

    values = Map.values(hand_map) |> Enum.sort()

    values =
      if has_joker and !only_joker_hand do
        values = values -- [joker_count]

        highest_value = Enum.max(values)

        (values -- [highest_value]) ++ [highest_value + joker_count]
      else
        values
      end

    cond do
      only_joker_hand && distinct_cards_count == 0 -> 1
      distinct_cards_count == 1 -> 1
      distinct_cards_count == 2 && values == [1, 4] -> 2
      distinct_cards_count == 2 && values == [2, 3] -> 3
      distinct_cards_count == 3 && values == [1, 1, 3] -> 4
      distinct_cards_count == 3 && values == [1, 2, 2] -> 5
      distinct_cards_count == 4 && values == [1, 1, 1, 2] -> 6
      distinct_cards_count == length(values) -> 7
    end
  end

  def get_card_strength(hand, :part1) do
    hand
    |> String.to_charlist()
    |> Enum.map(fn c ->
      case c do
        65 -> 1
        75 -> 2
        81 -> 3
        74 -> 4
        84 -> 5
        57 -> 6
        56 -> 7
        55 -> 8
        54 -> 9
        53 -> 10
        52 -> 11
        51 -> 12
        50 -> 13
      end
    end)
  end

  def get_card_strength(hand, :part2) do
    hand
    |> String.to_charlist()
    |> Enum.map(fn c ->
      case c do
        65 -> 1
        75 -> 2
        81 -> 3
        84 -> 5
        57 -> 6
        56 -> 7
        55 -> 8
        54 -> 9
        53 -> 10
        52 -> 11
        51 -> 12
        50 -> 13
        74 -> 14
      end
    end)
  end

  def card_sorter(hand1, hand2, part) do
    hand1_strength = hand1 |> get_hand_type_strength(part)
    hand2_strength = hand2 |> get_hand_type_strength(part)

    if hand1_strength == hand2_strength do
      hand1_card_strengh = hand1 |> get_card_strength(part)
      hand2_card_strengh = hand2 |> get_card_strength(part)

      hand1_card_strengh > hand2_card_strengh
    else
      hand1_strength > hand2_strength
    end
  end

  def p1(input) do
    hands =
      input
      |> parse_input()

    hands
    |> Enum.sort(fn {hand1, _}, {hand2, _} -> card_sorter(hand1, hand2, :part1) end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn entry, acc ->
      {{_hand, bid}, index} = entry

      acc + (index + 1) * bid
    end)
  end

  def p2(input) do
    hands =
      input
      |> parse_input()

    hands
    |> Enum.sort(fn {hand1, _}, {hand2, _} -> card_sorter(hand1, hand2, :part2) end)
    |> Enum.with_index()
    |> Enum.reduce(0, fn entry, acc ->
      {{_hand, bid}, index} = entry

      acc + (index + 1) * bid
    end)
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day07.txt"]))

    input
  end

  def read_input(false) do
    """
    AAAAA 2
    22222 3
    AAAAK 5
    22223 7
    AAAKK 11
    22233 13
    AAAKQ 17
    22234 19
    AAKKQ 23
    22334 29
    AAKQJ 31
    22345 37
    AKQJT 41
    23456 43
    """
  end

  def solve() do
    input = read_input(true)

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    :ok
  end
end