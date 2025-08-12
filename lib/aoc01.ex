defmodule AOC.Elixir01 do
  @input_path "inputs/input01.txt"

  def parse_input do
    {left, right} =
      File.stream!(@input_path)
      |> Enum.map(&String.trim_trailing(&1, "\n"))
      |> Enum.map(&String.split(&1, ~r" +"))
      |> Enum.map(fn row ->
        Enum.map(row, &String.to_integer/1)
      end)
      |> Enum.map(&List.to_tuple/1)
      |> Enum.unzip()

    {Enum.sort(left), Enum.sort(right)}
  end

  # Part 1
  def part1(left, right) do
    Enum.zip(left, right)
    |> Enum.map(fn {l, r} ->
      abs(l - r)
    end)
    |> Enum.sum()
  end

  # Part 2
  def part2(left, right) do
    freqs = Enum.frequencies(right)

    Enum.map(left, fn num ->
      num * Map.get(freqs, num, 0)
    end)
    |> Enum.sum()
  end
end

# # Solution
# {l, r} = AOC.Elixir01.parse_input()
# AOC.Elixir01.part1(l, r)
# AOC.Elixir01.part2(l, r)
