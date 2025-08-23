defmodule AOC.Elixir14 do
  def parse_input(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row/1)
  end

  def parse_row(row) do
    [col, row, vcol, vrow] =
      Regex.scan(~r|-*[0-9]+|, row)
      |> List.flatten()
      |> Enum.map(&String.to_integer/1)

    {{row, col}, {vrow, vcol}}
  end

  def move_robot({{row, col}, {vrow, vcol}}, {rowsize, colsize}) do
    new_row = rem(row + vrow + rowsize, rowsize)
    new_col = rem(col + vcol + colsize, colsize)
    {{new_row, new_col}, {vrow, vcol}}
  end

  def calculate_quadrants(robots, {rowsize, colsize}) do
    mid_row = div(rowsize - 1, 2)
    mid_col = div(colsize - 1, 2)

    robots
    |> Enum.reduce([0, 0, 0, 0], fn {{row, col}, _v}, [q1, q2, q3, q4] ->
      cond do
        row < mid_row and col < mid_col ->
          [q1 + 1, q2, q3, q4]

        row < mid_row and col > mid_col ->
          [q1, q2 + 1, q3, q4]

        row > mid_row and col < mid_col ->
          [q1, q2, q3 + 1, q4]

        row > mid_row and col > mid_col ->
          [q1, q2, q3, q4 + 1]

        true ->
          [q1, q2, q3, q4]
      end
    end)
    |> Enum.product()
  end

  def part1(input, n, {rowsize, colsize}) do
    Stream.iterate(input, fn robot_list ->
      Enum.map(robot_list, &move_robot(&1, {rowsize, colsize}))
    end)
    |> Enum.at(n)
    |> calculate_quadrants({rowsize, colsize})
  end

  def count_length_in_row(row, cols, positions) do
    {max_len_in_row, _} =
      cols
      |> Enum.map(&{row, &1})
      |> Enum.reduce({0, 0}, fn pos, {max_len, current_len} ->
        if MapSet.member?(positions, pos) do
          new_len = current_len + 1
          {max(max_len, new_len), new_len}
        else
          {max_len, 0}
        end
      end)

    max_len_in_row
  end

  def count_longest_row(robots, {rowsize, colsize}) do
    positions = Enum.reduce(robots, MapSet.new(), fn {pos, _vel}, acc -> MapSet.put(acc, pos) end)

    all_rows = 0..(rowsize - 1)
    all_cols = 0..(colsize - 1)

    all_rows
    |> Enum.map(&count_length_in_row(&1, all_cols, positions))
    |> Enum.max()
  end

  def print_positions(robots, {rowsize, colsize}) do
    positions = Enum.reduce(robots, MapSet.new(), fn {pos, _vel}, acc -> MapSet.put(acc, pos) end)

    map =
      0..(rowsize - 1)
      |> Enum.map(fn row ->
        0..(colsize - 1)
        |> Enum.map(fn col ->
          if MapSet.member?(positions, {row, col}) do
            ?#
          else
            ?.
          end
        end)
        |> List.to_string()
      end)

    map
    |> Enum.each(fn row -> IO.inspect(row) end)
  end

  def part2(input, {rowsize, colsize}, desired_len) do
    {_, seconds} =
      Stream.iterate({input, 0}, fn {robot_list, n} ->
        new_list = Enum.map(robot_list, &move_robot(&1, {rowsize, colsize}))
        {new_list, n + 1}
      end)
      |> Enum.find(fn {robots, _} ->
        count_longest_row(robots, {rowsize, colsize}) >= desired_len
      end)

    seconds
  end
end

# # Solutions
# input = File.read!("inputs/input14.txt") |> AOC.Elixir14.parse_input()
#
# AOC.Elixir14.part1(input, 100, {103, 101})
#
# AOC.Elixir14.part2(input, {103, 101}, 10)

# # Testing
# check = "p=0,4 v=3,-3
# p=6,3 v=-1,-3
# p=10,3 v=-1,2
# p=2,0 v=2,-1
# p=0,0 v=1,3
# p=3,0 v=-2,-2
# p=7,6 v=-1,-3
# p=3,0 v=-1,-2
# p=9,3 v=2,3
# p=7,3 v=-1,2
# p=2,4 v=2,-3
# p&=9,5 v=-3,-3" |> AOC.Elixir14.parse_input()
#
# Stream.iterate({{4, 2}, {-3, 2}}, &AOC.Elixir14.move_robot(&1, {7, 11}))
# |> Enum.take(10)
#
# AOC.Elixir14.calculate_quadrants(check, {7, 11})
#
# # AOC.Elixir14.part1(check, 100, {7, 11})
# # |> AOC.Elixir14.calculate_quadrants({7, 11})
#
# AOC.Elixir14.count_longest_row(input, {103, 101})
#
# AOC.Elixir14.part2(check, {7, 11}, 4)
#
# target =
#   Stream.iterate(input, fn robot_list ->
#     Enum.map(robot_list, &AOC.Elixir14.move_robot(&1, {103, 101}))
#   end)
#   |> Enum.at(7132)
#   |> AOC.Elixir14.count_longest_row({103, 101})
#   |> AOC.Elixir14.print_positions({103, 101})
#
# AOC.Elixir14.print_positions(check, {7, 11})
