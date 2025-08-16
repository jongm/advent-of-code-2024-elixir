defmodule AOC.Elixir12 do
  def parse_input(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  def in_bounds?({row, col}, size) do
    row >= 0 and row < size and col >= 0 and col < size
  end

  def iloc({row, col}, matrix) do
    matrix |> elem(row) |> elem(col)
  end

  def find_next_directions({row, col}) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.map(fn {dir_r, dir_c} -> {dir_r + row, dir_c + col} end)
  end

  def find_cluster({row, col}, input) do
    cluster_name = iloc({row, col}, input)

    cluster = MapSet.new([{row, col}])

    size = tuple_size(input)

    {final, _, _} =
      Stream.iterate({cluster, MapSet.new(), cluster}, fn {members, seen, next} ->
        new_seen =
          next
          |> Enum.map(&find_next_directions/1)
          |> List.flatten()
          |> Enum.uniq()
          |> Enum.filter(&in_bounds?(&1, size))
          |> Enum.reject(&MapSet.member?(seen, &1))
          |> MapSet.new()

        new_in_cluster = MapSet.filter(new_seen, fn pos -> iloc(pos, input) == cluster_name end)

        {MapSet.union(members, new_in_cluster), MapSet.union(seen, new_seen), new_in_cluster}
      end)
      |> Enum.take_while(fn {_members, _seen, next} -> MapSet.size(next) > 0 end)
      |> List.last()

    final
  end

  def find_all_clusters(input) do
    size = tuple_size(input)

    positions = for r <- 0..(size - 1), c <- 0..(size - 1), do: {r, c}

    {all_clusters, _all_seen} =
      positions
      |> Enum.reduce({[], MapSet.new()}, fn pos, {clusters, seen} ->
        if MapSet.member?(seen, pos) do
          {clusters, seen}
        else
          new_cluster = find_cluster(pos, input)
          {[new_cluster | clusters], MapSet.union(seen, new_cluster)}
        end
      end)

    all_clusters
  end

  def find_walls({row, col}, cluster) do
    find_next_directions({row, col})
    |> Enum.reject(&MapSet.member?(cluster, &1))
    |> Enum.count()
  end

  def count_walls(cluster) do
    Enum.reduce(cluster, 0, fn pos, walls -> walls + find_walls(pos, cluster) end)
  end

  def part1(clusters) do
    clusters
    |> Enum.map(&{MapSet.size(&1), count_walls(&1)})
    |> Enum.reduce(0, fn {size, walls}, sum -> sum + size * walls end)
  end

  def find_next_directions_and_facing({row, col}) do
    # The coordinates of the wall become {row_pos, col_pos, row_facing, col_facing}
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    |> Enum.map(fn {dir_r, dir_c} -> {dir_r + row, dir_c + col, dir_r, dir_c} end)
  end

  def find_cluster_sides(cluster) do
    cluster
    |> Enum.reduce(MapSet.new(), fn {row, col}, acc ->
      find_next_directions_and_facing({row, col})
      |> Enum.reject(fn {r, c, _, _} -> MapSet.member?(cluster, {r, c}) end)
      |> MapSet.new()
      |> MapSet.union(acc)
    end)
  end

  def same_side?({row1, col1, dir_r1, dir_c1}, {row2, col2, dir_r2, dir_c2}) do
    wall_connected = abs(row1 - row2) + abs(col1 - col2) == 1
    same_direction = dir_r1 == dir_r2 and dir_c1 == dir_c2
    wall_connected and same_direction
  end

  def find_contiguous_side(current_sides, candidates) do
    new_sides =
      current_sides
      |> Enum.map(fn side ->
        MapSet.filter(candidates, &same_side?(&1, side))
      end)
      |> Enum.reduce(MapSet.new(), fn new, acc -> MapSet.union(acc, new) end)

    if MapSet.size(new_sides) == 0 do
      current_sides
    else
      find_contiguous_side(
        MapSet.union(current_sides, new_sides),
        MapSet.difference(candidates, new_sides)
      )
    end
  end

  def count_sides(sides) do
    {sides_count, _seen} =
      sides
      |> Enum.reduce({0, MapSet.new()}, fn side, {sum, seen} ->
        if MapSet.member?(seen, side) do
          {sum, seen}
        else
          curr = MapSet.new([side])
          cand = MapSet.difference(sides, curr)
          contiguous = find_contiguous_side(curr, cand)
          {sum + 1, MapSet.union(seen, contiguous)}
        end
      end)

    sides_count
  end

  def part2(clusters) do
    clusters
    |> Enum.map(&{MapSet.size(&1), find_cluster_sides(&1)})
    |> Enum.reduce(0, fn {size, sides}, sum -> sum + size * count_sides(sides) end)
  end
end

# Solutions
input = File.read!("inputs/input12.txt") |> AOC.Elixir12.parse_input()
clusters = AOC.Elixir12.find_all_clusters(input)

AOC.Elixir12.part1(clusters)

AOC.Elixir12.part2(clusters)

# # Testing
# check = "RRRRIICCFF
# RRRRIICCCF
# VVRRRCCFFF
# VVRCCCJFFF
# VVVVCJJCFE
# VVIVCCJJEE
# VVIIICJJEE
# MIIIIIJJEE
# MIIISIJEEE
# MMMISSJEEE" |> AOC.Elixir12.parse_input()
#
# clusters = AOC.Elixir12.find_all_clusters(check)
#
# all_sides = AOC.Elixir12.find_cluster_sides(hd(clusters))
#
# AOC.Elixir12.count_sides(all_sides)
#
# AOC.Elixir12.iloc({2, 3}, check)
#
# AOC.Elixir12.find_cluster({0, 0}, check)
#
# AOC.Elixir12.part1(clusters)
# AOC.Elixir12.part2(clusters)
#
# AOC.Elixir12.find_next_directions_and_facing({0, 0})
#
# AOC.Elixir12.same_side?({8, 3, 0, -1}, {9, 3, 0, -1})
#
# curr = MapSet.new([{8, 3, 0, -1}])
# cand = MapSet.difference(all_sides, curr)
# AOC.Elixir12.find_contiguous_side(curr, cand)
