defmodule Day03 do
  def part_one(input) do
    one_liner_input =
      input
      |> String.replace("\n", "")
      |> String.trim()

    input_array = input |> String.split("\n", trim: true)
    width = input_array |> hd() |> String.length()
    height = input_array |> length()

    symbol_locations = find_symbol_locations(one_liner_input)

    number_locations =
      find_number_locations(input_array, width)
      |> Enum.map(fn {{number_loc_start, number_loc_end}, value} ->
        {number_loc_start..number_loc_end |> Enum.to_list(), value}
      end)
      |> List.flatten()

    symbol_locations
    |> Enum.map(fn symbol_loc ->
      locations_of_interest =
        get_surrounding_locations(symbol_loc, height, width)

      number_locations
      |> Enum.filter(fn {index_range, _value} ->
        index_range
        |> Enum.any?(fn index -> Enum.member?(locations_of_interest, index) end)
      end)
    end)
    |> List.flatten()
    |> Enum.dedup()
    |> Enum.reduce(0, fn {_, value}, acc -> acc + value end)
  end

  def part_two(input) do
    one_liner_input =
      input
      |> String.replace("\n", "")
      |> String.trim()

    input_array = input |> String.split("\n", trim: true)
    width = input_array |> hd() |> String.length()
    height = input_array |> length()

    symbol_locations = find_symbol_locations(one_liner_input)

    number_locations =
      find_number_locations(input_array, width)
      |> Enum.map(fn {{number_loc_start, number_loc_end}, value} ->
        {number_loc_start..number_loc_end |> Enum.to_list(), value}
      end)
      |> List.flatten()

    symbol_locations
    |> Enum.map(fn symbol_loc ->
      locations_of_interest =
        get_surrounding_locations(symbol_loc, height, width)

      number_locations
      |> Enum.filter(fn {index_range, _value} ->
        index_range
        |> Enum.any?(fn index -> Enum.member?(locations_of_interest, index) end)
      end)
    end)
    |> Enum.filter(fn numbers -> length(numbers) == 2 end)
    |> Enum.map(fn numbers ->
        {_, val1} = List.first(numbers)
        {_, val2} = List.last(numbers)

        val1 * val2
    end)
    |> Enum.sum()
  end

  def find_number_locations(input_array, width) do
    regex = ~r/([\d]+)/

    input_array
    |> Enum.with_index()
    |> Enum.flat_map(fn {input, index} ->
      numbers =
        Regex.scan(regex, input, return: :binary)
        |> Enum.map(fn [n | _] ->
          {parsed, _} = Integer.parse(n)
          parsed
        end)

      Regex.scan(regex, input, return: :index)
      |> Enum.reduce([], fn match, acc ->
        {start, length} = hd(match)
        acc ++ [{index * width + start, index * width + start + length - 1}]
      end)
      |> Enum.zip(numbers)
    end)
  end

  def find_symbol_locations(one_liner_input) do
    Regex.scan(~r/[!@#$%^&*()_+\-=\[\]{};':"\\|,<>\/?]/, one_liner_input, return: :index)
    |> Enum.reduce([], fn match, acc ->
      {index, _} = hd(match)
      acc ++ [index]
    end)
  end

  def get_surrounding_locations(index, height, width) do
    left = if valid_location?(index, height, width, :left), do: [index - 1], else: []
    right = if valid_location?(index, height, width, :right), do: [index + 1], else: []
    bottom = if valid_location?(index, height, width, :bottom), do: [index + width], else: []
    top = if valid_location?(index, height, width, :top), do: [index - width], else: []

    top_left =
      if valid_location?(index, height, width, :top) &&
           valid_location?(index, height, width, :left),
         do: [index - 1 - width],
         else: []

    top_right =
      if valid_location?(index, height, width, :top) &&
           valid_location?(index, height, width, :right),
         do: [index - width + 1],
         else: []

    bottom_left =
      if valid_location?(index, height, width, :bottom) &&
           valid_location?(index, height, width, :left),
         do: [index + width - 1],
         else: []

    bottom_right =
      if valid_location?(index, height, width, :bottom) &&
           valid_location?(index, height, width, :right),
         do: [index + width + 1],
         else: []

    top_left ++
      top ++
      top_right ++
      left ++
      right ++
      bottom_left ++ bottom ++ bottom_right
  end

  def valid_location?(index, _height, width, :right), do: rem(index, width) < width - 1
  def valid_location?(index, _height, width, :left), do: rem(index, width) > 0
  def valid_location?(index, _height, width, :top), do: div(index, width) > 0
  def valid_location?(index, height, width, :bottom), do: div(index, width) < height

  def solve() do
    {:ok, input_one} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day03.part1.txt"]))

    example_input = """
    467..114..
    ...*......
    ..35..633.
    ......#...
    617*......
    .....+.58.
    ..592.....
    ......755.
    ...$.*....
    .664.598..
    """

    #part_one(input_one)
    part_two(input_one)
  end
end