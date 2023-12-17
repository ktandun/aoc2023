defmodule Day08 do
  def parse_input(input) do
    [instruction, desert_map] =
      input
      |> String.split("\n\n", trim: true)

    desert_map =
      desert_map
      |> String.split("\n", trim: true)
      |> Enum.reduce(%{}, fn line, acc ->
        [from, left, right] =
          Regex.scan(~r/([0-9A-Z]{3}) = \(([0-9A-Z]{3}), ([0-9A-Z]{3})\)/, line,
            capture: :all_but_first
          )
          |> hd()

        Map.put(acc, from, %{"L" => left, "R" => right})
      end)

    {instruction, desert_map}
  end

  def count_steps_to_destination_p1(desert_map, instruction) do
    instruction_map =
      instruction
      |> String.graphemes()
      |> Enum.with_index()
      |> Map.new(fn {v, k} -> {k, v} end)

    instruction_length = map_size(instruction_map)
    location = "AAA"

    {_, steps} =
      Stream.iterate(0, &(&1 + 1))
      |> Enum.reduce_while({location, 0}, fn x, {curr_loc, step_count} ->
        curr_instruction =
          instruction_map
          |> Map.get(rem(x, instruction_length))

        curr_loc =
          desert_map
          |> Map.get(curr_loc)
          |> Map.get(curr_instruction)

        if curr_loc != "ZZZ" do
          {:cont, {curr_loc, step_count + 1}}
        else
          {:halt, {curr_loc, step_count + 1}}
        end
      end)

    steps
  end

  def count_steps_to_destination_p2(desert_map, instruction) do
    instruction_map =
      instruction
      |> String.graphemes()
      |> Enum.with_index()
      |> Map.new(fn {v, k} -> {k, v} end)

    instruction_length = map_size(instruction_map)

    starting_locations =
      desert_map
      |> Map.keys()
      |> Enum.filter(fn k -> String.ends_with?(k, "A") end)

    steps =
      starting_locations
      |> Enum.map(fn starting_location ->
        Stream.iterate(0, &(&1 + 1))
        |> Enum.reduce_while({starting_location, 0}, fn x, {curr_loc, step_count} ->
          curr_instruction =
            instruction_map
            |> Map.get(rem(x, instruction_length))

          curr_loc =
            desert_map
            |> Map.get(curr_loc)
            |> Map.get(curr_instruction)

          reach_dest = String.ends_with?(curr_loc, "Z")

          if !reach_dest do
            {:cont, {curr_loc, step_count + 1}}
          else
            {:halt, {curr_loc, step_count + 1}}
          end
        end)
      end)

    {_, step_one_count} = steps |> hd()

    steps
    |> Enum.reduce(step_one_count, fn {_, steps_count}, acc ->
      Math.lcm(acc, steps_count)
    end)
  end

  def p1(input) do
    {instruction, desert_map} =
      input
      |> parse_input()

    desert_map
    |> count_steps_to_destination_p1(instruction)
  end

  def p2(input) do
    {instruction, desert_map} =
      input
      |> parse_input()

    desert_map
    |> count_steps_to_destination_p2(instruction)
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day08.txt"]))

    input
  end

  def read_input(false) do
    """
    LR

    11A = (11B, XXX)
    11B = (XXX, 11Z)
    11Z = (11B, XXX)
    22A = (22B, XXX)
    22B = (22C, 22C)
    22C = (22Z, 22Z)
    22Z = (22B, 22B)
    XXX = (XXX, XXX)
    """
  end

  def solve() do
    input = read_input(true)

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    :ok
  end
end