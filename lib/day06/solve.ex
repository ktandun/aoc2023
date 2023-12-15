defmodule Day06 do
  def parse_input(input, :part1) do
    lines =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [_ | rest] = String.split(line, " ", trim: true)

        rest |> Enum.map(&String.to_integer/1)
      end)

    [time, distance] = lines

    Enum.zip(time, distance)
  end

  def parse_input(input, :part2) do
    lines =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [_ | rest] = String.split(line, " ", trim: true)

        rest |> Enum.join("") |> String.to_integer()
      end)

    lines
    |> List.to_tuple()
  end

  def find_ways_to_win({time, distance}) do
    0..time
    |> Enum.reduce(0, fn charge_time, acc ->
      remaining_time = time - charge_time
      travelled_distance = remaining_time * charge_time

      if travelled_distance > distance, do: acc + 1, else: acc
    end)
  end

  def p1(input) do
    time_distance_records =
      input
      |> parse_input(:part1)

    time_distance_records
    |> Enum.map(&find_ways_to_win/1)
    |> Enum.reduce(1, fn winning_ways, acc -> winning_ways * acc end)
  end

  def p2(input) do
    time_distance_record =
      input
      |> parse_input(:part2)

    find_ways_to_win(time_distance_record)
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day06.txt"]))

    input
  end

  def read_input(false) do
    """
    Time:      7  15   30
    Distance:  9  40  200
    """
  end

  def solve() do
    input = read_input(true)

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    "done"
  end
end
