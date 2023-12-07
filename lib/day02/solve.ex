defmodule Day02 do
  def part_one(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn record, acc ->
      {game_number, r, g, b} = read_game_record(record)

      acc +
        case {r, g, b} do
          {r, g, b} when r <= 12 and g <= 13 and b <= 14 -> game_number
          _ -> 0
        end
    end)
  end

  def part_two(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.reduce(0, fn record, acc ->
      {_, r, g, b} = read_game_record(record)

      acc + r * g * b
    end)
  end

  def read_game_record(record) do
    game = Regex.scan(~r/^Game ([\d]+)/, record)
    [_ | game_number] = hd(game)
    {game_number, _} = Integer.parse(hd(game_number))

    blue = get_color_count(record, :blue, :max)
    red = get_color_count(record, :red, :max)
    green = get_color_count(record, :green, :max)

    {game_number, red, green, blue}
  end

  def get_color_count(record, color) do
    regex =
      case color do
        :blue -> ~r/([\d]+) blue/
        :red -> ~r/([\d]+) red/
        :green -> ~r/([\d]+) green/
      end

    Regex.scan(regex, record)
    |> Enum.map(fn [_ | count] ->
      {number, _} = Integer.parse(hd(count))
      number
    end)
  end

  def get_color_count(record, color, :max), do: get_color_count(record, color) |> Enum.max()
  def get_color_count(record, color, :min), do: get_color_count(record, color) |> Enum.min()

  def solve() do
    {:ok, input_one} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day02.part1.txt"]))

    example_input = """
    Game 1: 3 blue, 4 red; 1 red, 2 green, 6 blue; 2 green
    Game 2: 1 blue, 2 green; 3 green, 4 blue, 1 red; 1 green, 1 blue
    Game 3: 8 green, 6 blue, 20 red; 5 blue, 4 red, 13 green; 5 green, 1 red
    Game 4: 1 green, 3 red, 6 blue; 3 green, 6 red; 3 green, 15 blue, 14 red
    Game 5: 6 red, 1 blue, 3 green; 2 blue, 1 red, 2 green
    """

    part_one(input_one)
    |> IO.inspect()

    part_two(input_one)
    |> IO.inspect()
  end
end
