defmodule Day10 do
  def parse_input(input) do
    maze_map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        line
        |> String.graphemes()
        |> Enum.with_index()
        |> Map.new(fn {v, k} -> {k, v} end)
      end)
      |> Enum.with_index()
      |> Map.new(fn {v, k} -> {k, v} end)

    height =
      maze_map
      |> map_size()

    width =
      maze_map[0]
      |> map_size()

    {maze_map, width - 1, height - 1}
  end

  def find_start(maze_map) do
    {row, _} =
      maze_map
      |> Enum.find(fn {_height, row} ->
        row
        |> Enum.find(fn {_width, col} ->
          col == "S"
        end)
      end)

    {col, _} =
      maze_map[row]
      |> Enum.find(fn {_width, col} ->
        col == "S"
      end)

    {row, col}
  end

  def get_connected_pipes(maze_map, row, col, max_height, max_width) do
    [
      {:down, row - 1, col},
      {:up, row + 1, col},
      {:right, row, col - 1},
      {:left, row, col + 1}
    ]
    |> Enum.filter(fn {direction, r, c} ->
      r >= 0 && r <= max_height &&
        c >= 0 && c <= max_width &&
        letter_to_direction(maze_map[r][c])
        |> Enum.member?(direction)
    end)
  end

  def letter_to_direction(letter) do
    case letter do
      "|" -> [:up, :down]
      "-" -> [:left, :right]
      "L" -> [:up, :right]
      "J" -> [:up, :left]
      "7" -> [:left, :down]
      "F" -> [:right, :down]
      "." -> [:none]
      _ -> [:none]
    end
  end

  def traverse_pipes(_, _, _, [], traversed_map), do: traversed_map

  def traverse_pipes(
        maze_map,
        max_height,
        max_width,
        queue,
        traversed_map
      ) do
    {{row, col, distance}, remaining_queue} =
      queue
      |> List.pop_at(0)

    traversed_map =
      traversed_map
      |> Map.put({row, col}, distance)

    connected_pipes =
      maze_map
      |> get_connected_pipes(row, col, max_height, max_width)
      |> Enum.filter(fn {_, r, c} -> not Map.has_key?(traversed_map, {r, c}) end)
      |> Enum.map(fn {_, r, c} -> {r, c, distance + 1} end)

    queue = remaining_queue ++ connected_pipes

    traverse_pipes(maze_map, max_height, max_width, queue, traversed_map)
  end

  def p1(input) do
    {maze_map, max_width, max_height} =
      input
      |> parse_input()

    {start_row, start_col} =
      maze_map
      |> find_start()

    maze_map
    |> traverse_pipes(max_height, max_width, [{start_row, start_col, 0}], Map.new())
    |> Map.values()
    |> Enum.sort(:desc)
  end

  def p2(input) do
    input
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day10.txt"]))

    input
  end

  def read_input(false) do
    """
    .....
    .S-7.
    .|.|.
    .L-J.
    .....
    """
  end

  def solve() do
    input = read_input(true)

    p1(input) |> IO.inspect()
    # p2(input) |> IO.inspect()

    :ok
  end
end