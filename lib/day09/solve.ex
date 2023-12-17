defmodule Day09 do
  def parse_input(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      String.split(line, " ", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def get_next_sequence(input_line) do
    all_zero =
      input_line
      |> Enum.all?(fn x -> x == 0 end)

    if all_zero do
      0
    else
      last_item = List.last(input_line)

      next_sequence =
        input_line
        |> get_diff()
        |> get_next_sequence()

      last_item + next_sequence
    end
  end

  def get_diff(input_line) do
    without_first_item =
      input_line
      |> List.delete_at(0)

    without_first_item
    |> Enum.zip(input_line)
    |> Enum.map(fn {left, right} -> left - right end)
  end

  def p1(input) do
    input =
      input
      |> parse_input()

    input
    |> Enum.map(&get_next_sequence/1)
    |> Enum.sum()
  end

  def p2(input) do
    input =
      input
      |> parse_input()

    input
    |> Enum.map(fn x -> Enum.reverse(x) end)
    |> Enum.map(&get_next_sequence/1)
    |> Enum.sum()
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day09.txt"]))

    input
  end

  def read_input(false) do
    """
    0 3 6 9 12 15
    1 3 6 10 15 21
    10 13 16 21 30 45
    """
  end

  def solve() do
    input = read_input(true)

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    :ok
  end
end