defmodule AOC.Elixir13 do
  def parse_row(row) do
    [[ax], [bx]] = Regex.scan(~r|(?<=X\+)[0-9]+|, row)
    [[ay], [by]] = Regex.scan(~r|(?<=Y\+)[0-9]+|, row)
    [[tx], [ty]] = Regex.scan(~r|(?<=[XY]=)[0-9]+|, row)

    [ax, ay, bx, by, tx, ty] =
      [ax, ay, bx, by, tx, ty]
      |> Enum.map(&String.to_integer/1)

    {{ax, ay}, {bx, by}, {tx, ty}}
  end

  def parse_input(raw) do
    raw
    |> String.split("\n\n")
    |> Enum.map(&parse_row/1)
  end

  def find_button_presses({{ax, ay}, {bx, by}, {tx, ty}}) do
    # Case B math
    b_case =
      if rem(ay * tx - ax * ty, ay * bx - ax * by) != 0 do
        nil
      else
        b_presses = div(ay * tx - ax * ty, ay * bx - ax * by)
        remain_a_x = tx - b_presses * bx
        remain_a_y = ty - b_presses * by

        if rem(remain_a_x, ax) != 0 do
          nil
        else
          a_press_for_x = div(remain_a_x, ax)
          a_press_for_y = div(remain_a_y, ay)

          cond do
            a_press_for_x != a_press_for_y -> nil
            a_press_for_x < 0 -> nil
            b_presses < 0 -> nil
            true -> {a_press_for_x, b_presses}
          end
        end
      end

    # Case A math
    a_case =
      if rem(by * tx - bx * ty, by * ax - bx * ay) != 0 do
        nil
      else
        a_presses = div(by * tx - bx * ty, by * ax - bx * ay)
        remain_b_x = tx - a_presses * ax
        remain_b_y = ty - a_presses * ay

        if rem(remain_b_x, bx) != 0 do
          nil
        else
          b_press_for_x = div(remain_b_x, bx)
          b_press_for_y = div(remain_b_y, by)

          cond do
            b_press_for_x != b_press_for_y -> nil
            b_press_for_x < 0 -> nil
            a_presses < 0 -> nil
            true -> {a_presses, b_press_for_x}
          end
        end
      end

    cond do
      b_case == nil and a_case == nil ->
        nil

      b_case == nil and a_case != nil ->
        a_case

      b_case != nil and a_case == nil ->
        b_case

      true ->
        a_price = elem(a_case, 0) * 3 + elem(a_case, 1)
        b_price = elem(b_case, 0) * 3 + elem(b_case, 1)

        if a_price <= b_price do
          a_case
        else
          b_case
        end
    end
  end

  def part1(input) do
    input
    |> Enum.map(&find_button_presses/1)
    |> Enum.filter(& &1)
    |> Enum.filter(fn {a, b} -> a > 0 and a <= 100 and b > 0 and b <= 100 end)
    |> Enum.map(fn {a, b} -> a * 3 + b end)
    |> Enum.sum()
  end

  def part2(input) do
    input
    |> Enum.map(fn {a, b, {tx, ty}} ->
      {a, b, {tx + 10_000_000_000_000, ty + 10_000_000_000_000}}
    end)
    |> Enum.map(&find_button_presses/1)
    |> Enum.filter(& &1)
    |> Enum.filter(fn {a, b} -> a > 0 and b > 0 end)
    |> Enum.map(fn {a, b} -> a * 3 + b end)
    |> Enum.sum()
  end
end

# # Solutions
# input = File.read!("inputs/input13.txt") |> AOC.Elixir13.parse_input()
#
# AOC.Elixir13.part1(input)
#
# AOC.Elixir13.part2(input)

# # Testing
# {a, b, t} = {{94, 34}, {22, 67}, {8400, 5400}}
# AOC.Elixir13.find_button_presses({a, b, t})
#
# row = "Button A: X+14, Y+89\nButton B: X+38, Y+40\nPrize: X=2186, Y=3415"
#
# check = "Button A: X+94, Y+34
# Button B: X+22, Y+67
# Prize: X=8400, Y=5400\n
# Button A: X+26, Y+66
# Button B: X+67, Y+21
# Prize: X=12748, Y=12176\n
# Button A: X+17, Y+86
# Button B: X+84, Y+37
# Prize: X=7870, Y=6450\n
# Button A: X+69, Y+23
# Button B: X+27, Y+71
# Prize: X=18641, Y=10279" |> AOC.Elixir13.parse_input()
#
# AOC.Elixir13.part1(check)
#
# AOC.Elixir13.part2(check)
#
# input
# |> Enum.map(&AOC.Elixir13.find_button_presses/1)
# |> Enum.filter(& &1)
# |> Enum.filter(fn {a, b} -> a > 0 and a <= 100 and b > 0 and b <= 100 end)
#
# check
# |> Enum.map(fn {a, b, {tx, ty}} ->
#   {a, b, {tx + 10_000_000_000_000, ty + 10_000_000_000_000}}
# end)
# |> Enum.map(&AOC.Elixir13.find_button_presses/1)
# |> Enum.at(0)
#
# {{ax, ay}, {bx, by}, {tx, ty}} = {{94, 34}, {22, 67}, {10_000_000_008_400, 10_000_000_005_400}}
