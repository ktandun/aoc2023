defmodule Aoc2023Test do
  use ExUnit.Case

  doctest Day05

  test "split_to_parts_p2" do
    input = """
    seeds: 1 10 2 20

    seed-to-soil map:
    50 98 2
    52 50 48
    """

    {seed, layers} = Day05.split_p2(input)

    assert [{1, 10}, {2, 21}] == seed
    assert [[{98, 99, 50, 51}, {50, 97, 52, 99}]] == layers
  end

  test "is_overlapping overlap left should return true" do
    assert true == Day05.is_overlapping({1, 10}, {5, 15})
  end

  test "is_overlapping overlap right should return true" do
    assert true == Day05.is_overlapping({14, 16}, {5, 15})
  end

  test "is_overlapping no overlap right should return false" do
    assert false == Day05.is_overlapping({25, 28}, {5, 15})
  end

  test "get_overlaps overlap left" do
    assert {5, 10} == Day05.get_overlaps({1, 10}, {5, 15})
  end

  test "get_overlaps overlap right" do
    assert {12, 15} == Day05.get_overlaps({12, 18}, {5, 15})
  end

  test "get_overlaps overlap both sides" do
    assert {5, 15} == Day05.get_overlaps({2, 18}, {5, 15})
  end

  test "get_overlaps overlap contained" do
    assert {7, 10} == Day05.get_overlaps({7, 10}, {5, 15})
  end

  test "map_overlaps overlap left" do
    assert {27, 30} == Day05.map_overlaps({7, 10}, {5, 15, 25, 35})
  end

  test "get_non_overlaps outer" do
    assert [{3, 4}, {16, 18}] == Day05.get_non_overlaps({3, 18}, [{5, 15, 100, 105}])
  end

  test "pass_through_layer" do
    assert [[{28, 30}]] == Day05.pass_through_layer({8, 10}, [{5, 15, 25, 35}])
  end

  test "pass_through_layer no matching" do
    assert [[{8, 10}]] == Day05.pass_through_layer({8, 10}, [{0, 5, 25, 35}])
  end

  test "pass_through_layer matching 2" do
    assert [[{25, 27}, {100, 101}]] ==
             Day05.pass_through_layer({5, 10}, [{8, 13, 25, 35}, {1, 7, 100, 107}])
  end
end
