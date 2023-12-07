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
    |> Enum.map(&find_digits/1)
    |> Enum.map(fn str ->
      {num, _} = Integer.parse(String.first(str) <> String.last(str))
      num
    end)
    |> Enum.sum()
  end

  def find_digits(string) do
    Regex.scan(
      ~r/(?=(one|two|three|four|five|six|seven|eight|nine|\d))/,
      string
    )
    |> List.flatten()
    |> Enum.map(fn x ->
      case x do
        "one" -> "1"
        "two" -> "2"
        "three" -> "3"
        "four" -> "4"
        "five" -> "5"
        "six" -> "6"
        "seven" -> "7"
        "eight" -> "8"
        "nine" -> "9"
        _ -> x
      end
    end)
    |> Enum.join("")
  end

  def solve() do
    {:ok, inputOne} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day01.part1.txt"]))

    part_one(inputOne)
    |> IO.inspect()

    part_two(inputOne)
    |> IO.inspect()
  end
end
