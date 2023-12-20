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
    [{row + 1, col, :north}, {row - 1, col, :south}, {row, col + 1, :west}, {row, col - 1, :east}]
    |> Stream.filter(fn {y, x, connectable_direction} ->
      0 <= y && y <= height &&
        0 <= x && x <= width &&
        maze_map[y][x]
        |> tiles_to_direction()
        |> Enum.member?(connectable_direction)
    end)
    |> Enum.map(fn {y, x, _} -> {y, x} end)
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

  def calculate_outside_nodes(row, line, connected_pipes_coords) do
    max = line |> Map.keys() |> Enum.max()

    {_status, count} =
      0..max
      |> Enum.reduce({:out, 0}, fn col, acc ->
        {status, count} = acc
        tile = line[col]

        status =
          case tile do
            "." -> status
            "-" -> status
            "|" -> reverse(status)
            "J" -> reverse(status)
            "L" -> reverse(status)
            "7" -> status
            "S" -> status
            "F" -> status
          end

        count =
          cond do
            not MapSet.member?(connected_pipes_coords, {row, col}) && status == :in -> count + 1
            true -> count
          end

        {status, count}
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
      |> MapSet.new()

    connected_pipes_coords
    |> MapSet.filter(fn {y, _x} -> y == 0 end)

    maze_map
    |> Enum.map(fn {k, v} -> calculate_outside_nodes(k, v, connected_pipes_coords) end)
    |> Enum.sum()
  end

  def read_input(true) do
    {:ok, input} =
      File.read(Path.join([System.get_env("HOME"), "advent_of_code_inputs", "day10.txt"]))

    input
  end

  def read_input(false) do
    """
    .F----7F7F7F7F-7....
    .|F--7||||||||FJ....
    .||.FJ||||||||L7....
    FJL7L7LJLJ||LJ.L-7..
    L--J.L7...LJS7F-7L7.
    ....F-J..F7FJ|L7L7L7
    ....L7.F7||L7|.L7L7|
    .....|FJLJ|FJ|F7|.LJ
    ....FJL-7.||.||||...
    ....L---J.LJ.LJLJ...
    """
  end

  def solve() do
    input = read_input(true)

    p1(input) |> IO.inspect()
    p2(input) |> IO.inspect()

    :ok
  end
end