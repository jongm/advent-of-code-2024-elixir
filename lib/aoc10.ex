defmodule AOC.Elixir10 do
  def parse_row(row) do
    row
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> List.to_tuple()
  end

  def parse_input(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row/1)
    |> List.to_tuple()
  end

  def in_bounds?({row, col}, size) do
    row >= 0 and row < size and col >= 0 and col < size
  end

  def check_path({new_row, new_col}, input, current) do
    new =
      input
      |> elem(new_row)
      |> elem(new_col)

    next =
      current + 1

    cond do
      current == 8 and new == 9 -> {new_row, new_col}
      new == next -> check_all_paths({new_row, new_col}, input, next)
      true -> nil
    end
  end

  def check_all_paths({row, col}, input, current \\ 0) do
    dirs = [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    size = tuple_size(input)

    dirs
    |> Enum.map(fn {dir_r, dir_c} -> {row + dir_r, col + dir_c} end)
    |> Enum.filter(&in_bounds?(&1, size))
    |> Enum.map(&check_path(&1, input, current))
    |> List.flatten()
    |> Enum.filter(& &1)
    |> Enum.uniq()
  end

  def part1(input) do
    size = tuple_size(input)
    positions = for row <- 0..(size - 1), col <- 0..(size - 1), do: {row, col}

    positions
    |> Enum.filter(fn {row, col} -> input |> elem(row) |> elem(col) == 0 end)
    |> Enum.map(&check_all_paths(&1, input, 0))
    |> Enum.map(&Enum.uniq/1)
    |> Enum.map(&Enum.count/1)
    |> Enum.sum()
  end

  def check_path_full({new_row, new_col}, input, current, seen) do
    new =
      input
      |> elem(new_row)
      |> elem(new_col)

    next =
      current + 1

    cond do
      current == 8 and new == 9 ->
        MapSet.put(seen, {new_row, new_col})

      new == next ->
        check_all_paths_full(
          {new_row, new_col},
          input,
          next,
          MapSet.put(seen, {new_row, new_col})
        )

      true ->
        nil
    end
  end

  def check_all_paths_full({row, col}, input, current \\ 0, seen) do
    dirs = [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    size = tuple_size(input)

    dirs
    |> Enum.map(fn {dir_r, dir_c} -> {row + dir_r, col + dir_c} end)
    |> Enum.filter(&in_bounds?(&1, size))
    |> Enum.map(&check_path_full(&1, input, current, seen))
    |> List.flatten()
    |> Enum.filter(& &1)
    |> Enum.uniq()
  end

  def part2(input) do
    size = tuple_size(input)
    positions = for row <- 0..(size - 1), col <- 0..(size - 1), do: {row, col}

    positions
    |> Enum.filter(fn {row, col} -> input |> elem(row) |> elem(col) == 0 end)
    |> Enum.map(&check_all_paths_full(&1, input, 0, MapSet.new([&1])))
    |> Enum.map(&Enum.uniq/1)
    |> Enum.map(&Enum.count/1)
    |> Enum.sum()
  end
end

# # Solutions
# input = File.read!("inputs/input10.txt") |> AOC.Elixir10.parse_input()
#
# AOC.Elixir10.part1(input)
#
# AOC.Elixir10.part2(input)
#
# # Testirg 
# check = "89010123
# 78121874
# 87430965
# 96549874
# 45678903
# 32019012
# 01329801
# 10456732" |> AOC.Elixir10.parse_input()
#
# AOC.Elixir10.part1(check)
#
# AOC.Elixir10.part2(check)
#
# size = tuple_size(check)
# positions = for row <- 0..(size - 1), col <- 0..(size - 1), do: {row, col}
#
# positions
# |> Enum.filter(fn {row, col} -> check |> elem(row) |> elem(col) == 0 end)
# |> Enum.map(&AOC.Elixir10.check_all_paths(&1, check, 0))
# |> Enum.map(&Enum.uniq/1)
# |> Enum.map(&Enum.count/1)
# |> Enum.sum()
#
# [{5, 2}]
# |> Enum.map(&AOC.Elixir10.check_all_paths_full(&1, check, 0))
#
# AOC.Elixir10.check_path_full({5, 3}, check, 0, MapSet.new())
#
# AOC.Elixir10.check_path({5, 3}, check, 0)
#
# AOC.Elixir10.check_all_paths_full({4, 6}, check, 0, MapSet.new([{5, 2}]))
