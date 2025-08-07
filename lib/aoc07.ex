defmodule AOC.Elixir07 do
  @input_path "inputs/input07.txt"

  def parse_row(row) do
    [target, nums] = String.split(row, ": ", trim: true)
    target = String.to_integer(target)

    nums =
      nums
      |> String.split(" ")
      |> Enum.map(&String.to_integer/1)

    {target, nums}
  end

  def parse_input do
    File.read!(@input_path)
    |> String.split("\n", trim: true)
    |> Enum.map(&parse_row/1)
  end

  def concat_nums(a, b) do
    (Integer.to_string(a) <> Integer.to_string(b))
    |> String.to_integer()
  end

  def do_operation([first | rest], op) do
    [next | others] = rest

    case op do
      :sum ->
        [first + next | others]

      :mul ->
        [first * next | others]

      :con ->
        [concat_nums(first, next) | others]
    end
  end

  def check_equation({target, nums}, operations) do
    if length(nums) == 1 do
      [result] = nums
      result == target
    else
      operations
      |> Enum.map(&do_operation(nums, &1))
      |> Enum.map(&check_equation({target, &1}, operations))
    end
  end

  def is_valid_equation?({target, nums}, operations) do
    check_equation({target, nums}, operations)
    |> List.flatten()
    |> Enum.any?()
  end

  def parts(input, ops) do
    input
    |> Enum.filter(&is_valid_equation?(&1, ops))
    |> Enum.reduce(0, fn {target, _}, acc -> acc + target end)
  end
end

# # Solutions
# input = AOC.Elixir07.parse_input()
# AOC.Elixir07.parts(input, [:sum, :mul])
# AOC.Elixir07.parts(input, [:sum, :mul, :con])

# # Testing
# raw = "
# 190: 10 19
# 3267: 81 40 27
# 83: 17 5
# 156: 15 6
# 7290: 6 8 6 15
# 161011: 16 10 13
# 192: 17 8 14
# 21037: 9 7 18 13
# 292: 11 6 16 20
# "
# (
# test_input =
#   String.split(raw, "\n", trim: true)
#   |> Enum.map(&AOC.Elixir07.parse_row/1)
# )
#
# AOC.Elixir07.parts(test_input, [:sum, :mul])
# AOC.Elixir07.parts(test_input, [:sum, :mul, :con])
#
# # AOC.Elixir07.do_operation([81, 40, 28], :sum)
# #
# # AOC.Elixir07.check_equation({3267, [81, 40, 27]}, [:sum, :mul])
# # |> Enum.concat()
# # |> Enum.any?()
#
# AOC.Elixir07.is_valid_equation?(Enum.at(test_input, 4), [:sum, :mul])
#
# AOC.Elixir07.check_equation(Enum.at(test_input, 4), [:sum, :mul])
# |> Enum.concat()
