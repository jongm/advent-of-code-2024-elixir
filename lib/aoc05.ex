defmodule AOC.Elixir05 do
  @input_path "inputs/input05.txt"

  def parse_input do
    [orders, updates] =
      File.read!(@input_path)
      |> String.split("\n\n", trim: true)

    orders =
      orders
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        row
        |> String.split("|")
        |> Enum.map(&String.to_integer/1)
      end)

    updates =
      updates
      |> String.split("\n", trim: true)
      |> Enum.map(fn row ->
        row
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)

    {orders, updates}
  end

  def get_afters(orders) do
    Enum.reduce(orders, %{}, fn [k, v], acc ->
      Map.update(acc, k, MapSet.new([v]), fn old ->
        MapSet.put(old, v)
      end)
    end)
  end

  def goes_after?(first, other, afters) do
    other in Map.get(afters, first)
  end

  def valid_update?([first | rest], afters) do
    # Enum.empty?(rest) or
    #   (rest
    #    |> Enum.map(&goes_after?(&1, first, afters))
    #    |> Enum.all?() and valid_update?(rest, afters))

    is_empty = Enum.empty?(rest)

    is_valid =
      rest
      |> Enum.map(&goes_after?(first, &1, afters))
      |> Enum.all?()

    next_valid =
      if is_empty do
        true
      else
        valid_update?(rest, afters)
      end

    # IO.puts("First: #{first}\nRest: ")
    # IO.inspect(rest, charlists: :as_lists)
    # IO.puts("\nEmpty: #{is_empty}, Valid: #{is_valid}, Next: #{next_valid}\n")

    is_empty or (is_valid and next_valid)
  end

  def part1(updates, afters) do
    updates
    |> Enum.filter(&valid_update?(&1, afters))
    |> Enum.map(fn list -> Enum.at(list, div(length(list), 2)) end)
    |> Enum.sum()
  end
end

# Solutions
{orders, updates} = AOC.Elixir05.parse_input()
afters = AOC.Elixir05.get_afters(orders)
AOC.Elixir05.part1(updates, afters)

Enum.at(updates, 1)
|> then(fn list -> Enum.at(list, div(length(list), 2)) end)

# AOC.Elixir05.valid_update?(
#   [92, 88, 34, 85, 87, 26, 29, 94, 93, 75, 12, 84, 13, 22, 76, 24, 53, 27, 91, 41, 39, 47, 25],
#   afters
# )
#
# orders
# |> Enum.filter(fn [l, r] -> l == 92 end)
# |> Enum.each(&IO.inspect(&1, charlists: :as_lists))
#
# Enum.map(
#   [
#     # 88,
#     # 34,
#     # 85,
#     # 87,
#     # 26,
#     # 29,
#     # 94,
#     # 93,
#     # 75,
#     # 12,
#     # 84,
#     # 13,
#     # 22,
#     # 76,
#     # 24,
#     # 53,
#     27,
#     91,
#     41,
#     39,
#     47,
#     25
#   ],
#   &AOC.Elixir05.goes_after?(92, &1, afters)
# )
# |> Enum.all?()
#
# AOC.Elixir05.goes_after?(92, 27, afters)
# AOC.Elixir05.goes_after?(27, 92, afters)
#
# Mop.keys(afters)
# |> Enum.map(fn key -> Map.get(afters, key) |> Enum.count() end)
# |> Enum.sum()
#
# Map.get(afters, 92)
#
# length(orders)
#
# # # Testing
# # orders
# # updates
# #
# # Map.get(afters, 34)
# # AOC.Elixir05.goes_after?(22, 34, afters)
# # AOC.Elixir05.goes_after?(102, 34, afters)
# # x = %{20 => [10, 30], 30 => [5, 10]}
