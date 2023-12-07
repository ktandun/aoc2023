defmodule Day01 do
  def part_one(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.replace(&1, ~r/\D/, ""))
    |> Enum.map(fn str ->
      {num, _} = Integer.parse(String.first(str) <> String.last(str))
      num
    end)
    |> Enum.sum()
  end

  def part_two(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&letters_to_digits/1)
    |> Enum.map(&String.replace(&1, ~r/\D/, ""))
    |> Enum.map(fn str ->
      {num, _} = Integer.parse(String.first(str) <> String.last(str))
      num
    |> IO.inspect()
    end)
    |> Enum.sum()
  end

  def letters_to_digits(string) do
    Regex.scan(~r/(?<one>one)|(?<two>two)|(?<three>three)|(?<four>four)|(?<five>five)|(?<six>six)|(?<seven>seven)|(?<eight>eight)|(?<nine>nine)/, string, capture: :first)
    |> Enum.flat_map(fn x -> x end)
    |> Enum.reduce("", fn x -> x end)
  end

  def solve() do
    {:ok, inputOne} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day01.part1.txt"]))

    part_one(inputOne)
    part_two("""
    two1nine
    eightwothree
    abcone2threexyz
    xtwone3four
    4nineeightseven2
    zoneight234
    7pqrstsixteen
    """)
  end
end
