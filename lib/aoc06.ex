defmodule AOC.Elixir06 do
  @input_path "inputs/input06.txt"
  @size 130

  def parse_input do
    File.read!(@input_path)
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def get_locations do
    for row <- 0..(@size - 1), col <- 0..(@size - 1), into: %MapSet{}, do: [row, col]
  end

  def find_start(locations, input) do
    Enum.filter(locations, fn [row, col] ->
      Enum.at(input, row)
      |> Enum.at(col) == ?^
    end)
    |> List.first()
  end

  def find_crates(locations, input) do
    Enum.filter(locations, fn [row, col] ->
      Enum.at(input, row)
      |> Enum.at(col) == ?#
    end)
  end

  def turn_right([dy, dx]) do
    [dx, -dy]
  end

  def move_function(crates) do
    fn {[y, x], [dy, dx]} ->
      next_pos = [y + dy, x + dx]

      if next_pos in crates do
        {[y, x], turn_right([dy, dx])}
      else
        {next_pos, [dy, dx]}
      end
    end
  end

  def get_visited_path(locations, crates, start) do
    up_dir = [-1, 0]
    move = move_function(crates)

    Stream.iterate({start, up_dir}, move)
    |> Enum.take_while(fn {pos, _} -> pos in locations end)
    |> Enum.reduce(MapSet.new(), fn {pos, _}, acc -> MapSet.put(acc, pos) end)
  end

  def part1(visited) do
    Enum.count(visited)
  end

  def move_and_check({start, dir}, locations, move_fun, seen) do
    {next_pos, next_dir} = move_fun.({start, dir})

    cond do
      {start, dir} in seen ->
        :loop

      next_pos not in locations ->
        :no_loop

      true ->
        move_and_check(
          {next_pos, next_dir},
          locations,
          move_fun,
          MapSet.put(seen, {start, dir})
        )
    end
  end

  def test_loop(locations, crates, start, new_crate) do
    up_dir = [-1, 0]
    new_crates = Enum.concat(crates, [new_crate])
    new_move_fun = move_function(new_crates)
    move_and_check({start, up_dir}, locations, new_move_fun, MapSet.new())
  end

  def part2(locations, crates, candidates, start) do
    candidates
    |> Enum.filter(&(&1 not in crates and &1 != start))
    |> Enum.map(&test_loop(locations, crates, start, &1))
    |> Enum.filter(&(&1 == :loop))
    |> Enum.count()
  end
end

# # Solutions
# IEx.configure(inspect: [charlists: :as_lists])
#
# input = AOC.Elixir06.parse_input()
# locations = AOC.Elixir06.get_locations()
# start = AOC.Elixir06.find_start(locations, input)
# crates = AOC.Elixir06.find_crates(locations, input)
# visited = AOC.Elixir06.get_visited_path(locations, crates, start)
#
# AOC.Elixir06.part1(visited)
#
# AOC.Elixir06.part2(locations, crates, visited, start)

# Testing
# IO.inspect(start, charlists: :as_list)
#
# move = AOC.Elixir06.move_function(crates)
# # up_dir = [-1, 0]
# # new_move_fun = AOC.Elixir06.move_function(crates)
# # AOC.Elixir06.move_and_check({start, up_dir}, locations, new_move_fun, MapSet.new())
# #
# # AOC.Elixir06.test_loop(locations, crates, start, [50, 51])
#
# move.({start, [-1, 0]})
#
# check =
#   MapSet.new([
#     {[113, 54], [-1, 0]},
#     {[114, 51], [0, -1]},
#     {[61, 62], [0, 1]},
#     {[94, 120], [1, 0]},
#     {[107, 75], [-1, 0]}
#   ])
#
# start = [94, 120]
# dir = [1, 0]
# {start, dir} in check
