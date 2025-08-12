defmodule AOC.Elixir08 do
  def parse_input(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_charlist/1)
  end

  def get_antennas(input) do
    size = length(input)
    positions = for row <- 0..(size - 1), col <- 0..(size - 1), do: {row, col}

    positions
    |> Enum.reduce(%{}, fn {row, col}, acc ->
      char = input |> Enum.at(row) |> Enum.at(col)

      case char do
        ?. ->
          acc

        _ ->
          current = Map.get(acc, char, [])
          Map.put(acc, char, [{row, col} | current])
      end
    end)
  end

  def find_pair({r1, c1}, {r2, c2}) do
    [{r1 * 2 - r2, c1 * 2 - c2}, {r2 * 2 - r1, c2 * 2 - c1}]
  end

  def find_antinodes([first | rest]) do
    if length(rest) == 0 do
      []
    else
      rest
      |> Enum.map(&find_pair(first, &1))
      |> List.flatten()
      |> Enum.concat(find_antinodes(rest))
      |> Enum.uniq()
    end
  end

  def in_bounds?({row, col}, size) do
    row >= 0 and row < size and col >= 0 and col < size
  end

  def part1(antenas, size) do
    Map.values(antenas)
    |> Enum.map(&find_antinodes/1)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(&in_bounds?(&1, size))
    |> Enum.count()
  end

  def next_resonance({r0, c0}, {r1, c1}, {r2, c2}) do
    {r1 + r0 - r2, c1 + c0 - c2}
  end

  def find_resonant_pairs({r1, c1}, {r2, c2}, size) do
    res1 =
      Stream.iterate({r1, c1}, &next_resonance({r1, c1}, &1, {r2, c2}))
      |> Enum.take_while(&in_bounds?(&1, size))

    res2 =
      Stream.iterate({r2, c2}, &next_resonance({r2, c2}, &1, {r1, c1}))
      |> Enum.take_while(&in_bounds?(&1, size))

    Enum.concat(res1, res2)
  end

  def find_resonant_antinodes([first | rest], size) do
    if length(rest) == 0 do
      []
    else
      rest
      |> Enum.map(&find_resonant_pairs(first, &1, size))
      |> List.flatten()
      |> Enum.concat(find_resonant_antinodes(rest, size))
      |> Enum.uniq()
    end
  end

  def part2(antenas, size) do
    Map.values(antenas)
    |> Enum.map(&find_resonant_antinodes(&1, size))
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.filter(&in_bounds?(&1, size))
    |> Enum.count()
  end
end

# # Solutions
# input = File.read!("inputs/input08.txt") |> AOC.Elixir08.parse_input()
# ant = AOC.Elixir08.get_antennas(input)
#
# AOC.Elixir08.part1(ant, length(input))
#
# AOC.Elixir08.part2(ant, length(input))

# # Testing
# length(Enum.at(input, 0))
#
# AOC.Elixir08.find_pair({3, 4}, {6, 2})
# AOC.Elixir08.find_antinodes([{3, 4}, {6, 2}])
# AOC.Elixir08.find_antinodes([{3, 4}, {6, 2}, {10, 5}])
#
# AOC.Elixir08.in_bounds?({9, 12})

# AOC.Elixir08.find_resonant_pairs({15, 15}, {21, 21})
#
# {r1, c1} = {15, 15}
# {r2, c2} = {21, 21}
#
# Stream.iterate({r1, c1}, &AOC.Elixir08.next_resonance({r1, c1}, &1, {r2, c2}))
# |> Enum.take_while(&AOC.Elixir08.in_bounds?/1)
#
# Stream.iterate({r2, c2}, &AOC.Elixir08.next_resonance({r2, c2}, &1, {r1, c1}))
# |> Enum.take_while(&AOC.Elixir08.in_bounds?/1)
