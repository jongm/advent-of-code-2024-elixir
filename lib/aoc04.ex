defmodule AOC.Elixir04 do
  def parse_input(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def count_xmas(string) do
    Regex.scan(~r/(?=(XMAS|SAMX))/, string)
    |> Enum.count()
  end

  def transpose(input) do
    input
    |> Enum.zip()
    |> Enum.map(&Tuple.to_list/1)
  end

  def in_bounds({row, col}, size) do
    row < size and col < size
  end

  def take_diagonal(input, start_row, start_col) do
    size = length(input)

    Stream.iterate({start_row, start_col}, fn {r, c} -> {r + 1, c + 1} end)
    |> Enum.take_while(&in_bounds(&1, size))
    |> Enum.map(fn {r, c} ->
      input
      |> Enum.at(r)
      |> Enum.at(c)
    end)
  end

  def all_diagonals(input) do
    size = length(input)

    Enum.map(0..(size - 1), &[{&1, 0}, {0, &1}])
    |> Enum.concat()
    |> Enum.uniq()
    |> Enum.map(fn {r, c} -> take_diagonal(input, r, c) end)
  end

  def part1(input) do
    Enum.concat([
      input,
      transpose(input),
      all_diagonals(input),
      all_diagonals(Enum.map(input, &Enum.reverse/1))
    ])
    |> Enum.map(&List.to_string/1)
    |> Enum.map(&count_xmas/1)
    |> Enum.sum()
  end

  def is_letter_a?({r, c}, input) do
    input
    |> Enum.at(r)
    |> Enum.at(c) == ?A
  end

  def valid_corners?({r, c}, input) do
    candidates = [~c"MMSS", ~c"SSMM", ~c"MSSM", ~c"SMMS"]
    directions = [{-1, -1}, {-1, 1}, {1, 1}, {1, -1}]

    cross =
      directions
      |> Enum.map(fn {dr, dc} -> {r + dr, c + dc} end)
      |> Enum.map(fn {new_r, new_c} ->
        input
        |> Enum.at(new_r)
        |> Enum.at(new_c)
      end)

    cross in candidates
  end

  def part2(input) do
    size = length(input)

    all_points =
      1..(size - 2)
      |> Enum.map(fn n -> Enum.map(1..(size - 2), &{&1, n}) end)
      |> Enum.concat()

    all_points
    |> Enum.filter(fn {r, c} ->
      is_letter_a?({r, c}, input) and valid_corners?({r, c}, input)
    end)
    |> Enum.count()
  end
end

# # Solutions
# input = File.read!("inputs/input04.txt") |> AOC.Elixir04.parse_input()
# AOC.Elixir04.part1(input)
# AOC.Elixir04.part2(input)

# # Testing
# AOC.Elixir04.is_letter_a?({0, 1}, input)
# AOC.Elixir04.valid_corners?({5, 5}, input)
# AOC.Elixir04.take_diagonal(input, 120, 0)
#
# AOC.Elixir04.all_diagonals(input)
#
# Regex.run(~r"[0-9]+", "123 asd 65")
#
# List.to_string(~c"123 asd 65")
#
# Enum.take(input, 3)
# |> Enum.map(&Enum.reverse/1)
#
# Enum.take(input, 1)
# |> Enum.map(&List.to_string/1)
#
# # |> Enum.sum()
#
# Regex.scan(~r/(?=(HOLA|LANA))/, "HOLANADA", capture: :all)
