defmodule Day04 do
  def part_one(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&read_card/1)
    |> Enum.sum()
  end

  def read_card(input_line) do
    input_line
    |> String.split(":")
    |> List.last()
    |> String.split("|")
    |> then(fn [winning, on_hand] ->
      winning_mapset =
        winning
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()

      on_hand_mapset =
        on_hand
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()

      winner_numbers =
        winning_mapset
        |> MapSet.intersection(on_hand_mapset)

      case MapSet.size(winner_numbers) do
        0 -> 0
        _ -> 2 ** (MapSet.size(winner_numbers) - 1)
      end
    end)
  end

  def part_two(input) do
    input_lines =
      input
      |> String.split("\n", trim: true)

    cards_count = length(input_lines)

    total =
      input_lines
      |> Enum.reduce(%{}, fn input_line, acc ->
        {card_number, win_count} =
          input_line
          |> read_card_part_two()

        case win_count do
          0 ->
            acc

          _ ->
            (card_number + 1)..(card_number + win_count)
            |> Enum.to_list()
            |> List.duplicate((acc[card_number] || 0) + 1)
            |> List.flatten()
            |> Enum.reduce(acc, fn card_num, acc2 ->
              Map.put(acc2, card_num, (acc2[card_num] || 0) + 1)
            end)
        end
      end)
      |> Map.values()
      |> Enum.sum()

    total + cards_count
  end

  def read_card_part_two(input_line) do
    [card_number_str | numbers] =
      input_line
      |> String.split(":")

    card_number =
      card_number_str
      |> String.split(" ")
      |> List.last()
      |> String.to_integer()

    numbers
    |> List.last()
    |> String.split("|")
    |> then(fn [winning, on_hand] ->
      winning_mapset =
        winning
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()

      on_hand_mapset =
        on_hand
        |> String.split(" ", trim: true)
        |> Enum.map(&String.to_integer/1)
        |> MapSet.new()

      win_count =
        winning_mapset
        |> MapSet.intersection(on_hand_mapset)
        |> MapSet.size()

      {card_number, win_count}
    end)
  end

  def solve() do
    {:ok, input_one} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day04.part1.txt"]))

    # part_one(input_one)
    part_two(input_one)
  end
end
