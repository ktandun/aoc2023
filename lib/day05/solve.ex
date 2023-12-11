defmodule Day05 do
  defp split_to_parts(input) do
    [seed | rest] =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn s -> String.split(s, ":", trim: true) |> List.last() end)
      |> Enum.map(fn s -> String.split(s, "\n", trim: true) end)

    seed =
      seed
      |> hd()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)

    rest =
      rest
      |> Enum.map(fn lines ->
        lines
        |> Enum.map(fn line ->
          String.split(line, " ", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)
        |> Enum.map(fn [dest, source, count] ->
          {source, dest, count}
        end)
      end)

    {seed, rest}
  end

  defp find_location({number, parts}) do
    parts
    |> Enum.reduce(number, fn part, acc ->
      found =
        part
        |> Enum.filter(fn {source, _dest, count} ->
          Enum.member?(source..(source + count - 1), acc)
        end)

      case found do
        [] -> acc
        [{source, dest, _count}] -> acc - source + dest
      end
    end)
  end

  def find_seed_ranges(seeds) do
    seeds
    |> Enum.chunk_every(2)
    |> Enum.map(fn [from, increment] -> from..(from + increment - 1) end)
  end

  def part_one(input) do
    {seeds, parts} =
      input
      |> split_to_parts()

    seeds
    |> Enum.map(fn seed -> find_location({seed, parts}) end)
    |> Enum.min()
  end

  def get_domain(number, parts) do
    parts
    |> Enum.reduce(number, fn part, acc ->
      found =
        part
        |> Enum.filter(fn {_source, dest, count} -> Enum.member?(dest..(dest + count - 1), acc) end)

      case found do
        [] -> acc
        [{source, dest, count}] -> acc - dest + source
      end
    end)
    |> dbg()
  end

  def part_two(input) do
    {seeds, parts} =
      input
      |> split_to_parts()

    parts = Enum.reverse(parts)

    #    seeds =
    #      seeds
    #      |> Enum.chunk_every(2)
    #      |> Enum.map(fn [start, length] ->
    #        start..(length + start - 1)
    #      end)

    Stream.iterate(1, fn x -> x + 1 end)
    |> Enum.take_while(fn number ->
        number
        |> Enum.map(fn number ->
          number
          |> get_domain(parts)
        end)
    end)
  end

  def solve() do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day05.part1.txt"]))

    example_input = """
    seeds: 79 14 55 13

    seed-to-soil map:
    50 98 2
    52 50 48

    soil-to-fertilizer map:
    0 15 37
    37 52 2
    39 0 15

    fertilizer-to-water map:
    49 53 8
    0 11 42
    42 0 7
    57 7 4

    water-to-light map:
    88 18 7
    18 25 70

    light-to-temperature map:
    45 77 23
    81 45 19
    68 64 13

    temperature-to-humidity map:
    0 69 1
    1 0 69

    humidity-to-location map:
    60 56 37
    56 93 4

    """

    # part_one(input)
    part_two(example_input)
  end
end
