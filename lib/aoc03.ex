defmodule AOC.Elixir03 do
  @input_path "inputs/input03.txt"

  def parse_input do
    File.read!(@input_path)
  end

  def do_operation(op) do
    [n1] = Regex.run(~r"[0-9]+(?=\))", op)
    [n2] = Regex.run(~r"(?<=\()[0-9]+", op)
    String.to_integer(n1) * String.to_integer(n2)
  end

  def calc_segment(string) do
    Regex.scan(~r"mul\([0-9]+,[0-9]+\)", string)
    |> Enum.map(&List.first/1)
    |> Enum.map(&do_operation/1)
    |> Enum.sum()
  end

  def do_first_half(string) do
    String.split(string, ~r"don't\(\)")
    |> List.first()
    |> calc_segment
  end

  def part2(string) do
    String.split(string, ~r"do\(\)")
    |> Enum.map(&do_first_half/1)
    |> Enum.sum()
  end
end

# Solutions
input = AOC.Elixir03.parse_input()
AOC.Elixir03.calc_segment(input)
AOC.Elixir03.part2(input)

# Testing 
AOC.Elixir03.do_operation("(12, 10)")
AOC.Elixir03.do_first_half(input)
