defmodule Day05 do
  def split(input, part) do
    [seed | rest] =
      input
      |> String.split("\n\n", trim: true)
      |> Enum.map(fn s -> String.split(s, ":", trim: true) |> List.last() end)
      |> Enum.map(fn s -> String.split(s, "\n", trim: true) end)

    seed_p1 =
      seed
      |> hd()
      |> String.split(" ", trim: true)
      |> Enum.map(fn s ->
          {String.to_integer(s), String.to_integer(s)}
      end)

    seed_p2 =
      seed
      |> hd()
      |> String.split(" ", trim: true)
      |> Enum.map(&String.to_integer/1)
      |> Enum.chunk_every(2)
      |> Enum.map(fn [from, count] ->
        {from, from+count-1}
      end)

    seed = if part == :part1, do: seed_p1, else: seed_p2

    rest =
      rest
      |> Enum.map(fn lines ->
        lines
        |> Enum.map(fn line ->
          String.split(line, " ", trim: true)
          |> Enum.map(&String.to_integer/1)
        end)
        |> Enum.map(fn [dest, source, count] ->
          {source, source + count - 1, dest, dest + count - 1}
        end)
      end)

    {seed, rest}
  end

  def is_overlapping({one_l, one_r}, {two_l, two_r}) do
    (two_l <= one_r && one_r <= two_r) || (two_l <= one_l && one_l <= two_r)
  end

  def get_overlaps({one_l, one_r}, {two_l, two_r}) do
    left = if two_l <= one_l && one_l <= two_r, do: one_l, else: two_l
    right = if two_l <= one_r && one_r <= two_r, do: one_r, else: two_r

    {left, right}
  end

  def map_overlaps(overlaps, layer) do
    {overlap_l, overlap_r} = overlaps
    {source_l, _source_r, dest_l, _dest_r} = layer

    delta = dest_l - source_l

    {overlap_l + delta, overlap_r + delta}
  end

  def get_non_overlaps(range1, []), do: [range1]

  def get_non_overlaps(range1, ranges2) do
    ranges2
    |> Enum.reduce([range1], fn range2, acc ->
      acc
      |> Enum.map(fn a -> subtract(a, range2) end)
      |> List.flatten()
    end)
  end

  # range1 - range2
  def subtract(range1, range2) do
    {r1_left, r1_right} = range1
    {r2_left, r2_right} = range2

    cond do
      r1_right < r2_left ->
        [range1]

      r2_right < r1_left ->
        [range1]

      # overlapping on left
      r2_left <= r1_left ->
        cond do
          r2_right < r1_right -> [{r2_right + 1, r1_right}]
          true -> []
        end

      # overlapping on right
      r1_right <= r2_right ->
        cond do
          r1_left < r2_left -> [{r1_left, r2_left - 1}]
          true -> []
        end

      # contained
      r1_left < r2_left && r2_right < r1_right ->
        [{r1_left, r2_left - 1}, {r2_right + 1, r1_right}]

      # non overlapping
      true ->
        [range1]
    end
  end

  def pass_through_layer(seed, layer) do
    mappings =
      layer
      |> Enum.filter(fn l ->
        {source_l, source_r, _, _} = l
        is_overlapping(seed, {source_l, source_r})
      end)

    non_overlaps = get_non_overlaps(seed, mappings |> Enum.map(fn {l, r, _, _} -> {l, r} end))

    res =
      if length(mappings) == 0 do
        [[seed]]
      else
        mappings
        |> Enum.map(fn mapping ->
          {source_l, source_r, _, _} = mapping

          overlaps =
            get_overlaps(seed, {source_l, source_r})
            |> map_overlaps(mapping)

          overlaps
        end)
      end

    res ++ non_overlaps
  end

  def process_seed_mapping(seed, layers) do
    layers
    |> Enum.reduce([seed], fn layer, acc ->
      acc
      |> Enum.map(fn a ->
        pass_through_layer(a, layer)
      end)
      |> List.flatten()
      |> Enum.dedup()
    end)
  end

  def p1(input) do
    {seeds, layers} =
      input
      |> split(:part1)

    seeds
    |> Enum.map(&process_seed_mapping(&1, layers))
    |> List.flatten()
    |> Enum.sort()
    |> Enum.take(1)
  end

  def p2(input) do
    {seeds, layers} =
      input
      |> split(:part2)

    seeds
    |> Enum.map(&process_seed_mapping(&1, layers))
    |> List.flatten()
    |> Enum.sort()
    |> Enum.take(1)
  end

  def read_input() do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day05.part1.txt"]))

    input
  end

  def read_input(:example) do
    """
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
  end

  def solve() do
    input = read_input()

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    "done"
  end
end
