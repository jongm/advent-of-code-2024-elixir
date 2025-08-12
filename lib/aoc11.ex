defmodule AOC.Elixir11 do
  def parse_input(raw) do
    raw
    |> String.trim("\n")
    |> String.split(" ", trim: true)
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end

  def apply_rule(stone) do
    stone_string = Integer.to_string(stone)
    stone_length = String.length(stone_string)

    cond do
      stone == 0 ->
        [1]

      rem(stone_length, 2) == 0 ->
        stone_string
        |> String.split_at(div(stone_length, 2))
        |> Tuple.to_list()
        |> Enum.map(&String.to_integer/1)

      true ->
        [stone * 2024]
    end
  end

  def update_one_stone({stone, n}, total) do
    new_stones = apply_rule(stone)

    new_stones
    |> Enum.reduce(
      Map.put(total, stone, Map.get(total, stone, 0) - n),
      fn new, acc -> Map.put(acc, new, Map.get(acc, new, 0) + n) end
    )
  end

  def update_stones(stones) do
    new_stones = stones

    Enum.reduce(stones, new_stones, fn {stone, n}, acc -> update_one_stone({stone, n}, acc) end)
  end

  def parts(input, times) do
    input
    |> Stream.iterate(&update_stones/1)
    |> Enum.at(times)
    |> Map.values()
    |> Enum.sum()
  end
end

# # Solutions
# input = File.read!("inputs/input11.txt") |> AOC.Elixir11.parse_input()
#
# AOC.Elixir11.parts(input, 25)
#
# AOC.Elixir11.parts(input, 75)

# # Testing
# "125 17"
# |> AOC.Elixir11.parse_input()
# |> Stream.iterate(&AOC.Elixir11.update_stones/1)
# |> Enum.at(6)
# |> Map.values()
# |> Enum.sum()
