defmodule Day11 do
  @galaxy "#"

  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
  end

  def find_cosmic_expansions(universe, galaxies) do
    sample =
      universe
      |> Enum.take(1)
      |> List.first()

    cols = String.length(sample)
    rows = length(universe)

    occupied_rows = galaxies |> Enum.map(fn {row, _} -> row end)
    occupied_cols = galaxies |> Enum.map(fn {_, col} -> col end)

    {0..(rows - 1) |> Enum.filter(fn col -> col not in occupied_rows end),
     0..(cols - 1) |> Enum.filter(fn col -> col not in occupied_cols end)}
  end

  def find_galaxies(universe) do
    universe
    |> Stream.with_index()
    |> Stream.filter(fn {line, _index} -> String.contains?(line, @galaxy) end)
    |> Stream.map(fn {line, row} ->
      Regex.scan(~r/\#/, line, return: :index)
      |> List.flatten()
      |> Enum.map(fn {col, _} -> {row, col} end)
    end)
    |> Enum.to_list()
    |> List.flatten()
  end

  def calc_shortest_distance(cosmic_expansions, cosmic_distance, galaxy1, galaxy2) do
    {g1y, g1x} = galaxy1
    {g2y, g2x} = galaxy2
    {cosmic_ys, cosmic_xs} = cosmic_expansions

    distance_without_expansion =
      abs(g1y - g2y) + abs(g1x - g2x)

    expansion_y =
      min(g1y, g2y)..max(g1y, g2y)
      |> Enum.filter(fn y -> y in cosmic_ys end)
      |> length

    expansion_x =
      min(g1x, g2x)..max(g1x, g2x)
      |> Enum.filter(fn x -> x in cosmic_xs end)
      |> length

    distance_without_expansion + cosmic_distance * (expansion_x + expansion_y)
  end

  def comb(0, _), do: [[]]
  def comb(_, []), do: []

  def comb(m, [h | t]) do
    for(l <- comb(m - 1, t), do: [h | l]) ++ comb(m, t)
  end

  def p1(input) do
    universe =
      input
      |> parse_input()

    galaxies =
      universe
      |> find_galaxies()

    cosmic_expansions =
      universe
      |> find_cosmic_expansions(galaxies)

    comb(2, galaxies)
    |> Enum.map(fn [galaxy1, galaxy2] ->
      calc_shortest_distance(cosmic_expansions, 1, galaxy1, galaxy2)
    end)
    |> Enum.sum()
  end

  def p2(input) do
    universe =
      input
      |> parse_input()

    galaxies =
      universe
      |> find_galaxies()

    cosmic_expansions =
      universe
      |> find_cosmic_expansions(galaxies)

    comb(2, galaxies)
    |> Enum.map(fn [galaxy1, galaxy2] ->
      calc_shortest_distance(cosmic_expansions, 999_999, galaxy1, galaxy2)
    end)
    |> Enum.sum()
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day11.txt"]))

    input
  end

  def read_input(false) do
    """
    ...#......
    .......#..
    #.........
    ..........
    ......#...
    .#........
    .........#
    ..........
    .......#..
    #...#.....
    """
  end

  def solve() do
    input = read_input(true)

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    :ok
  end
end