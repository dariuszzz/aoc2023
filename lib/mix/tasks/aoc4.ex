defmodule Mix.Tasks.Aoc4 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input4.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&part1/1, [file])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
    {p2time, p2} = :timer.tc(&part2/1, [file])
    IO.puts "Part 2: #{p2} - took #{p2time/1000}ms"
  end

  def part1(filestream) do
    filestream
      |> Enum.map(fn line ->
        line = String.trim(line)
        [_, nums] = String.split(line, ":")
        [winning, other] = String.split(nums, "|")
        winning = winning
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)

        other = other
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)

        other
          |> Enum.reduce(0, fn num, acc ->
            if num in winning do
              case acc do
                0 -> 1
                _ -> acc * 2
              end
            else
              acc
            end
          end)
      end)
      |> Enum.sum()
  end

  def part2(filestream) do
    map = filestream
      |> Enum.map(fn <<"Card ", rest::binary>> ->
        line = String.trim(rest)
        [card_id, nums] = String.split(line, ":")
        [winning, other] = String.split(nums, "|")
        winning = winning
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)

        other = other
          |> String.split(" ", trim: true)
          |> Enum.map(&String.to_integer/1)

        card_winning_amount = other
          |> Enum.reduce(0, fn num, acc ->
            case num in winning do
              true -> acc + 1
              false -> acc
            end
          end)

         {String.to_integer(card_id), card_winning_amount}
      end)

    actual_values = map
      |> Enum.reduce(%{}, fn {card_id, card_winnings}, acc ->
        case card_id do
          1 -> Map.put(acc, card_id, {card_winnings, 1})
          _ ->
            copy_count = 1..(card_id - 1)
              |> Enum.map(fn prev_card_id ->
                {prev_card_winnings, prev_card_copies} = acc[prev_card_id]
                {prev_card_id, prev_card_winnings, prev_card_copies}
              end)
              |> Enum.filter(fn {prev_card_id, prev_card_winnings, _} ->
                affected_range = (prev_card_id + 1)..(prev_card_id + prev_card_winnings)
                prev_card_winnings != 0 and card_id in affected_range
              end)
              |> Enum.reduce(1, fn {_, _, prev_card_copies}, acc ->
                acc + prev_card_copies
              end)

            Map.put(acc, card_id, {card_winnings, copy_count})
        end
      end)

    actual_values
      |> Enum.map(fn {_, {_, copies}} -> copies end)
      |> Enum.sum
  end

end
