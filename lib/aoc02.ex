defmodule AOC.Elixir02 do
  def parse_input(raw) do
    raw
    |> String.split("\n", trim: true)
    |> Enum.map(fn row ->
      String.split(row, " ")
      |> Enum.map(&String.to_integer/1)
    end)
  end

  def safe_row?(row) do
    difs =
      row
      |> Enum.chunk_every(2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    all_pos =
      difs
      |> Enum.map(&(&1 >= 0))
      |> Enum.all?()

    all_neg =
      difs
      |> Enum.map(&(&1 <= 0))
      |> Enum.all?()

    all_in_range =
      difs
      |> Enum.map(&abs/1)
      |> Enum.map(&(&1 >= 1 and &1 <= 3))
      |> Enum.all?()

    (all_pos or all_neg) and all_in_range
  end

  def part1(input) do
    input
    |> Enum.filter(&safe_row?/1)
    |> Enum.count()
  end

  def remove_n(row, n) do
    result =
      Enum.map(
        0..Enum.count(row),
        fn ix -> Enum.concat(Enum.take(row, ix), Enum.drop(row, ix + 1)) end
      )

    if n == 1 do
      result
    else
      Enum.concat(Enum.map(result, &remove_n(&1, n - 1)))
    end
  end

  def safe_by_n(row, n) do
    remove_n(row, n)
    |> Enum.map(&safe_row?/1)
    |> Enum.any?()
  end

  def part2(input, n) do
    input
    |> Enum.filter(&safe_by_n(&1, n))
    |> Enum.count()
  end
end

# # Solutions
# input = File.read!("inputs/input02.txt") |> AOC.Elixir02.parse_input()
# AOC.Elixir02.part1(input)
# AOC.Elixir02.part2(input, 1)

# # Testing
# row = [2, 5, 3, 7, 8]
# row2 = [10, 20, 30, 40, 50]
# AOC.Elixir02.safe_row?(row)
# AOC.Elixir02.remove_n(row2, 1)
# AOC.Elixir02.safe_by_n(row, 1)
