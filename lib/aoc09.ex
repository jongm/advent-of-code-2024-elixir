defmodule AOC.Elixir09 do
  def parse_input(raw) do
    raw
    |> String.trim("\n")
    |> String.split("", trim: true)
    |> Enum.map(&String.to_integer/1)
  end

  def expand_step({[data, space], id}) do
    List.duplicate(id, data) ++ List.duplicate(".", space)
  end

  def expand_diskmap(input) do
    input
    |> Enum.chunk_every(2, 2, [0])
    |> Enum.with_index()
    |> Enum.map(&expand_step/1)
    |> Enum.concat()
  end

  def compact_diskmap([first | rest]) do
    if length(rest) == 0 do
      case first do
        "." ->
          []

        _ ->
          [first]
      end
    else
      case first do
        "." ->
          {new, others} = List.pop_at(rest, -1)

          case new do
            "." ->
              compact_diskmap([first | others])

            _ ->
              [new | compact_diskmap(others)]
          end

        _ ->
          [first | compact_diskmap(rest)]
      end
    end
  end

  def calc_checksum(compacted) do
    Enum.with_index(compacted)
    |> Enum.reduce(0, fn {id, ix}, sum ->
      sum + id * ix
    end)
  end

  def part1(input) do
    input
    |> expand_diskmap()
    |> compact_diskmap()
    |> calc_checksum()
  end

  def defrag_diskmap_file(disk, target_id) do
    {possible, [target | tail]} =
      Enum.split_while(disk, fn {[_, _], id} -> id != target_id end)

    {[target_files, target_spaces], _id} = target

    {head, candidates} = Enum.split_while(possible, fn {[_, s], _} -> s < target_files end)

    if length(candidates) == 0 do
      disk
    else
      [new_loc | other_locs] = candidates

      {[new_files, new_spaces], new_id} = new_loc
      updated_new = {[new_files, 0], new_id}

      # if the occupied space is the one just before the target, then we increase the target spaces
      if length(other_locs) == 0 do
        updated_target =
          {[target_files, new_spaces - target_files + target_spaces + target_files], target_id}

        head ++ [updated_new] ++ [updated_target] ++ tail
        # if not then we have to increase the free space of the one before the target
      else
        updated_target = {[target_files, new_spaces - target_files], target_id}
        {{[pre_files, pre_spaces], pre_id}, final_other_locs} = List.pop_at(other_locs, -1)
        updated_pre = {[pre_files, pre_spaces + target_files + target_spaces], pre_id}

        head ++ [updated_new] ++ [updated_target] ++ final_other_locs ++ [updated_pre] ++ tail
      end
    end
  end

  def defrag_diskmap(disk, max_id) do
    new_disk =
      defrag_diskmap_file(disk, max_id)

    if max_id == 1 do
      new_disk
    else
      defrag_diskmap(new_disk, max_id - 1)
    end
  end

  def part2(input, size) do
    input
    |> Enum.chunk_every(2, 2, [0])
    |> Enum.with_index()
    |> AOC.Elixir09.defrag_diskmap(size)
    |> Enum.map(&AOC.Elixir09.expand_step/1)
    |> Enum.concat()
    |> Enum.map(fn x ->
      if x == "." do
        0
      else
        x
      end
    end)
    |> AOC.Elixir09.calc_checksum()
  end
end

# # Solutions
# input = File.read!("inputs/input09.txt") |> AOC.Elixir09.parse_input()
#
# AOC.Elixir09.part1(input)
#
# AOC.Elixir09.part2(input, 9999)
#
# # Testing
# "2333133121414131402"
# |> AOC.Elixir09.parse_input()
# |> AOC.Elixir09.expand_diskmap()
# |> AOC.Elixir09.compact_diskmap()
# |> AOC.Elixir09.calc_checksum()

#
# "2333133121414131402"
# |> String.split("", trim: true)
# |> Enum.map(&String.to_integer/1)
#
# check = input|> Enum.chunk_every(2, 2, [0])|> Enum.with_index()
# |> AOC.Elixir09.defrag_diskmap_file(10000)
#
# "2333133121414131402"
# |> String.split("", trim: true)
# |> Enum.map(&String.to_integer/1)
# |> Enum.chunk_every(2, 2, [0])
# |> Enum.with_index()
# |> AOC.Elixir09.defrag_diskmap(9)
# |> Enum.map(&AOC.Elixir09.expand_step/1)
# |> Enum.concat()
# |> Enum.map(fn x ->
#   if x == "." do
#     0
#   else
#     x
#   end
# end)
#
# |> AOC.Elixir09.calc_checksum()
