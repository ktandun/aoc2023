defmodule Day10 do
  def parse_input(input) do
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
  end

  def get_dimensions(maze_map) do
    y = maze_map |> Map.keys()
    x = maze_map[0] |> Map.keys()

    {Enum.min(y), Enum.max(y), Enum.min(x), Enum.max(x)}
  end

  def find_start(maze_map) do
    {_, height, _, width} = get_dimensions(maze_map)

    for y <- 0..height,
        x <- 0..width,
        maze_map[y][x] == "S" do
      {y, x}
    end
    |> List.first()
  end

  def tiles_to_direction(tile) do
    case tile do
      "|" -> [:north, :south]
      "-" -> [:west, :east]
      "L" -> [:north, :east]
      "J" -> [:north, :west]
      "7" -> [:south, :west]
      "F" -> [:south, :east]
      "." -> [:none]
      "S" -> [:north, :south, :west, :east]
    end
  end

  def get_connected_pipes(maze_map, height, width, row, col) do
    connectable_direction =
      maze_map[row][col]
      |> tiles_to_direction()

    [
      {row + 1, col, :south, :north},
      {row - 1, col, :north, :south},
      {row, col + 1, :east, :west},
      {row, col - 1, :west, :east}
    ]
    |> Stream.filter(fn {y, x, direction, from_direction} ->
      0 <= y && y <= height &&
        0 <= x && x <= width &&
        direction in connectable_direction &&
        maze_map[y][x]
        |> tiles_to_direction()
        |> Enum.member?(from_direction)
    end)
    |> Enum.map(fn {y, x, _, _} -> {y, x} end)
  end

  def get_connected_dots(dimensions, row, col) do
    {ymin, ymax, xmin, xmax} = dimensions

    [{row + 1, col}, {row - 1, col}, {row, col + 1}, {row, col - 1}]
    |> Enum.filter(fn {y, x} ->
      ymin <= y && y <= ymax &&
        xmin <= x && x <= xmax
    end)
  end

  def find_connected_nodes(maze_map, queue) do
    [{start_row, start_col}] = queue
    dimensions = get_dimensions(maze_map)

    find_connected_nodes_helper(maze_map, dimensions, [{start_row, start_col, 0}], Map.new())
  end

  def find_connected_nodes_helper(_, _, [], result_map), do: result_map

  def find_connected_nodes_helper(maze_map, dimensions, queue, result_map) do
    {_, height, _, width} = dimensions

    {{row, col, distance}, remaining_queue} = List.pop_at(queue, 0)

    result_map = Map.put(result_map, {row, col}, distance)

    connected_nodes =
      get_connected_pipes(maze_map, height, width, row, col)
      |> Stream.filter(fn {y, x} -> not Map.has_key?(result_map, {y, x}) end)
      |> Enum.map(fn {y, x} -> {y, x, distance + 1} end)

    queue = remaining_queue ++ connected_nodes

    find_connected_nodes_helper(maze_map, dimensions, queue, result_map)
  end

  def add_buffer(maze_map) do
    {_, height, _, width} = get_dimensions(maze_map)

    for x <- -1..(width + 1), y <- -1..(height + 1) do
      {y, x}
    end
    |> Enum.reduce(maze_map, fn curr, acc ->
      {y, x} = curr

      if Map.has_key?(acc, y) && Map.has_key?(acc[y], x) do
        acc
      else
        curr = Map.get(acc, y, %{})
        y_map = Map.put(curr, x, ".")
        Map.put(acc, y, y_map)
      end
    end)
  end

  def find_connected_dots(maze_map, queue, connected_pipes_coords) do
    [{start_row, start_col}] = queue
    dimensions = get_dimensions(maze_map)

    find_connected_dots_helper(
      maze_map,
      dimensions,
      connected_pipes_coords,
      [{start_row, start_col}],
      MapSet.new()
    )
  end

  def find_connected_dots_helper(_, _, _, [], result_map), do: result_map

  def find_connected_dots_helper(maze_map, dimensions, connected_pipes_coords, queue, result_map) do
    {{row, col}, remaining_queue} = List.pop_at(queue, 0)

    result_map = MapSet.put(result_map, {row, col})

    connected_nodes =
      get_connected_dots(dimensions, row, col)
      |> Enum.filter(fn {y, x} ->
        not MapSet.member?(result_map, {y, x}) &&
          not MapSet.member?(connected_pipes_coords, {y, x}) &&
          not Enum.member?(remaining_queue, {y, x})
      end)

    queue = remaining_queue ++ connected_nodes

    find_connected_dots_helper(maze_map, dimensions, connected_pipes_coords, queue, result_map)
  end

  def reverse(:out), do: :in
  def reverse(:in), do: :out

  def calculate_inside_nodes(row, line, connected_pipes_coords) do
    max = line |> Map.keys() |> Enum.max()

    {_status, count, _prev_corner} =
      0..max
      |> Enum.reduce({:out, 0, nil}, fn col, acc ->
        {status, count, prev_corner} = acc
        tile = if line[col] == "S", do: "J", else: line[col]

        part_of_maze = MapSet.member?(connected_pipes_coords, {row, col})

        {status, prev_corner} =
          case {part_of_maze, tile, prev_corner} do
            {false, _, _} -> {status, prev_corner}
            {true, ".", _} -> {status, prev_corner}
            {true, "-", _} -> {status, prev_corner}
            {true, "|", _} -> {reverse(status), prev_corner}
            {true, "7", "L"} -> {reverse(status), nil}
            {true, "J", "F"} -> {reverse(status), nil}
            {true, "J", _} -> {status, "J"}
            {true, "L", _} -> {status, "L"}
            {true, "7", _} -> {status, "7"}
            {true, "F", _} -> {status, "F"}
          end

        count =
          case {part_of_maze, status} do
            {false, :in} -> count + 1
            _ -> count
          end

        {status, count, prev_corner}
      end)

    count
  end

  def p1(input) do
    maze_map =
      input
      |> parse_input()

    {start_row, start_col} =
      maze_map
      |> find_start()

    maze_map
    |> find_connected_nodes([{start_row, start_col}])
    |> Map.values()
    |> Enum.sort(:desc)
    |> Enum.take(1)
  end

  def p2(input) do
    maze_map =
      input
      |> parse_input()

    {start_row, start_col} =
      maze_map
      |> find_start()

    connected_pipes_coords =
      maze_map
      |> find_connected_nodes([{start_row, start_col}])
      |> Map.keys()
      |> Enum.sort()
      |> MapSet.new()

    maze_map
    |> Enum.map(fn {k, v} -> calculate_inside_nodes(k, v, connected_pipes_coords) end)
    |> Enum.sum()
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day10.txt"]))

    input
  end

  def read_input(false) do
    """
    FF7FSF7F7F7F7F7F---7
    L|LJ||||||||||||F--J
    FL-7LJLJ||||||LJL-77
    F--JF--7||LJLJ7F7FJ-
    L---JF-JLJ.||-FJLJJ7
    |F|F-JF---7F7-L7L|7|
    |FFJF7L7F-JF7|JL---7
    7-L-JL7||F7|L7F-7F7|
    L.L7LFJ|||||FJL7||LJ
    L7JLJL-JLJLJL--JLJ.L
    """
  end

  def to_box_chars(input) do
    input
    |> String.replace("F", "┌")
    |> String.replace("L", "└")
    |> String.replace("J", "┘")
    |> String.replace("7", "┐")
    |> String.replace("-", "─")
    |> String.replace("|", "│")
    |> String.split("\n", trim: true)
  end

  def solve() do
    input = read_input(true)
    input |> to_box_chars() |> IO.inspect()

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    :ok
  end
end
