defmodule AOC.Elixir15 do
  def parse_input(raw) do
    [map, moves] = String.split(raw, "\n\n", trim: true)

    map =
      String.split(map, "\n", trim: true)
      |> Enum.map(&String.to_charlist/1)
      |> Enum.map(&List.to_tuple/1)
      |> List.to_tuple()

    moves =
      String.split(moves, "\n", trim: true)
      |> Enum.map(&String.to_charlist/1)
      |> List.flatten()

    {map, moves}
  end

  def print_map(map) do
    map
    |> Tuple.to_list()
    |> Enum.each(fn row ->
      row
      |> Tuple.to_list()
      |> List.to_string()
      |> IO.puts()
    end)
  end

  def iloc({row, col}, matrix) do
    matrix |> elem(row) |> elem(col)
  end

  def find_next_pos({start_row, start_col}, move) do
    case move do
      ?v -> {start_row + 1, start_col}
      ?^ -> {start_row - 1, start_col}
      ?< -> {start_row, start_col - 1}
      ?> -> {start_row, start_col + 1}
    end
  end

  def find_character(map) do
    start_row =
      map
      |> Tuple.to_list()
      |> Enum.find_index(fn row ->
        row
        |> Tuple.to_list()
        |> Enum.member?(?@)
      end)

    start_col =
      elem(map, start_row)
      |> Tuple.to_list()
      |> Enum.find_index(fn elem -> elem == ?@ end)

    {start_row, start_col}
  end

  def find_moves(from, move, map) do
    next_pos = find_next_pos(from, move)
    mover = iloc(from, map)
    next_mover = iloc(next_pos, map)
    possible = next_mover != ?#

    instruction = {next_pos, mover, possible}

    if next_mover == ?O do
      [instruction | find_moves(next_pos, move, map)]
    else
      [instruction]
    end
  end

  def apply_move({{row, col}, item, _possible}, map) do
    put_elem(map, row, put_elem(elem(map, row), col, item))
  end

  def attempt_one_move(start_pos, move, map) do
    all_moves = find_moves(start_pos, move, map)
    all_possible = Enum.all?(all_moves, fn {_, _, poss} -> poss end)

    if all_possible do
      {next_pos, _, _} = hd(all_moves)

      final_map =
        [{start_pos, ?., true} | all_moves]
        |> Enum.reduce(map, fn move, acc -> apply_move(move, acc) end)

      {next_pos, final_map}
    else
      {start_pos, map}
    end
  end

  def calculate_boxes(map) do
    rows = tuple_size(map)
    cols = tuple_size(elem(map, 0))

    positions = for row <- 0..(rows - 1), col <- 0..(cols - 1), do: {row, col}

    positions
    |> Enum.reduce(0, fn {row, col}, acc ->
      if iloc({row, col}, map) in [?O, ?[] do
        acc + row * 100 + col
      else
        acc
      end
    end)
  end

  def part1(map, moves) do
    start_pos = find_character(map)

    {_, final_map} =
      moves
      |> Enum.reduce({start_pos, map}, fn move, {pos, acc} -> attempt_one_move(pos, move, acc) end)

    calculate_boxes(final_map)
  end

  def expand_map(map) do
    map
    |> Tuple.to_list()
    |> Enum.map(fn row ->
      row
      |> Tuple.to_list()
      |> Enum.map(fn element ->
        case element do
          ?# -> ~c"##"
          ?O -> ~c"[]"
          ?. -> ~c".."
          ?@ -> ~c"@."
        end
      end)
      |> List.flatten()
      |> List.to_tuple()
    end)
    |> List.to_tuple()
  end

  def find_moves_wide(from, move, map) do
    next_pos = find_next_pos(from, move)
    {next_row, next_col} = next_pos
    mover = iloc(from, map)
    next_mover = iloc(next_pos, map)
    possible = next_mover != ?#

    instruction = [{from, ?., true}, {next_pos, mover, possible}]

    cond do
      move in [?<, ?>] ->
        case next_mover do
          ?] -> instruction ++ find_moves_wide(next_pos, move, map)
          ?[ -> instruction ++ find_moves_wide(next_pos, move, map)
          _ -> instruction
        end

      move in [?^, ?v] ->
        case next_mover do
          ?] ->
            instruction ++
              find_moves_wide(next_pos, move, map) ++
              find_moves_wide({next_row, next_col - 1}, move, map)

          ?[ ->
            instruction ++
              find_moves_wide(next_pos, move, map) ++
              find_moves_wide({next_row, next_col + 1}, move, map)

          _ ->
            instruction
        end
    end
  end

  def attempt_one_move_wide(start_pos, move, map) do
    all_moves = find_moves_wide(start_pos, move, map)
    all_possible = Enum.all?(all_moves, fn {_, _, poss} -> poss end)

    if all_possible do
      next_pos = find_next_pos(start_pos, move)

      final_map =
        all_moves
        |> Enum.split_with(fn {_, item, _} -> item == ?. end)
        |> Tuple.to_list()
        |> List.flatten()
        |> Enum.reduce(map, fn move, acc -> apply_move(move, acc) end)

      {next_pos, final_map}
    else
      {start_pos, map}
    end
  end

  def part2(map, moves) do
    map_wide = expand_map(map)
    start_pos = find_character(map_wide)

    {_, final_map} =
      moves
      |> Enum.reduce({start_pos, map_wide}, fn move, {pos, acc} ->
        attempt_one_move_wide(pos, move, acc)
      end)

    calculate_boxes(final_map)
  end
end

# # Solutions
# {map, moves} = File.read!("inputs/input15.txt") |> AOC.Elixir15.parse_input()
#
# AOC.Elixir15.part1(map, moves)
#
# AOC.Elixir15.part2(map, moves)
#
# # Testing
# test = "##########
# #..O..O.O#
# #......O.#
# #.OO..O.O#
# #..O@..O.#
# #O#..O...#
# #O..O..O.#
# #.OO.O.OO#
# #....O...#
# ##########\n
# <vv>^<v^>v>^vv^v>v<>v^v<v<^vv<<<^><<><>>v<vvv<>^v^>^<<<><<v<<<v^vv^v>^
# vvv<<^>^v^^><<>>><>^<<><^vv^^<>vvv<>><^^v>^>vv<>v<<<<v<^v>^<^^>>>^<v<v
# ><>vv>v^v^<>><>>>><^^>vv>v<^^^>>v^v^<^^>v^^>v^<^v>v<>>v^v^<v>v^^<^^vv<
# <<v<^>>^^^^>>>v^<>vvv^><v<<<>^^^vv^<vvv>^>v<^^^^v<>^>vvvv><>>v^<<^^^^^
# ^><^><>>><>^^<<^^v>>><^<v>^<vv>>v>>>^v><>^v><<<<v>>v<v<v>vvv>^<><<>^><
# ^>><>^v<><^vvv<^^<><v<<<<<><^v<<<><<<^^<v<^^^><^>>^<v^><<<^>>^v<v^v<v^
# >^>>^v>vv>^<<^v<>><<><<v<<v><>v<^vv<<<>^^v^>^^>>><<^v>>v^v><^^>>^<>vv^
# <><^^>^^^<><vvvvv^v<v<<>^v<v>v<<^><<><<><<<^^<<<^<<>><<><^^^>^^<>^>v<>
# ^^>vv<^v^v<vv>^<><v<^v>^^^>>>^^vvv^>vvv<>>>^<^>>>>>^<<^v>^vvv<>^<><<v>
# v^^>>><<^^<>>^v^<v^vv<>v^<<>^<^v^v><^<<<><<^<v><v<>vv>>v><v^<vv<>v^<<^"
#
# {tmap, tmoves} = AOC.Elixir15.parse_input(test)
#
# tmapw = AOC.Elixir15.expand_map(tmap)
#
# tstart = AOC.Elixir15.find_character(tmapw)
#
# AOC.Elixir15.print_map(tmapw)
#
# AOC.Elixir15.find_moves_wide(tstart, ?<, tmapw)
#
# AOC.Elixir15.part1(tmap, tmoves)
# AOC.Elixir15.part2(tmap, tmoves)
#
# "<v<^^^^"
# |> String.to_charlist()
# |> Enum.reduce({tstart, tmapw}, fn move, {pos, map} ->
#   {new_pos, new_map} = AOC.Elixir15.attempt_one_move_wide(pos, move, map)
#   AOC.Elixir15.print_map(new_map)
#   {new_pos, new_map}
# end)
#
# AOC.Elixir15.apply_move({{4, 3}, 64, true}, tmap)
#
# AOC.Elixir15.calculate_boxes(tmap)
#
# {_, new} = AOC.Elixir15.attempt_one_move({4, 8}, ?<, tmap)
#
# AOC.Elixir15.print_map(tmap)
