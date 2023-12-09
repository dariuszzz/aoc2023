defmodule Mix.Tasks.Aoc9 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input9.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&part1/1, [file])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
    {p2time, p2} = :timer.tc(&part2/1, [file])
    IO.puts "Part 2: #{p2} - took #{p2time/1000}ms"
  end

  def part1(filestream) do
    filestream
      |> parse_input()
      |> extrapolate(fn currList, prevList ->
        lastElementInPrev = Enum.at(prevList, -1)
        lastElementInCurr = Enum.at(currList, -1)

        currList ++ [lastElementInCurr + lastElementInPrev]
      end)
      |> Enum.map(&Enum.at(&1, -1))
      |> Enum.sum()
  end

  def part2(filestream) do
    filestream
      |> parse_input()
      |> extrapolate(fn currList, prevList ->
        firstElementInPrev = Enum.at(prevList, 0)
        firstElementInCurr = Enum.at(currList, 0)

        [firstElementInCurr - firstElementInPrev | currList]
      end)
      |> Enum.map(&Enum.at(&1, 0))
      |> Enum.sum()
  end

  def extrapolate(lists, f) do
    lists
      |> Enum.map(fn sequence ->
        sequence
          |> Enum.reverse()
          |> Enum.drop(1)
          |> Enum.reduce([0], f)
      end)
  end

  def parse_input(filestream) do
    filestream
      |> Enum.map(fn line ->
        line = String.trim(line)
        numbers = String.split(line, " ")
          |> Enum.map(&String.to_integer/1)

        reduce_until_all_zeroes([numbers])
      end)
  end

  def reduce_until_all_zeroes(lists) do
    newestList = Enum.at(lists, -1)
    allZeroes = Enum.all?(newestList, &(&1 == 0))
    case allZeroes do
      true -> lists
      false ->
        {diffList, _} = Enum.reduce(newestList, {[], nil}, fn elem, {list, prev} ->
          case prev do
            nil -> {list, elem}
            _ -> {list ++ [(elem - prev)], elem}
          end
        end)

        reduce_until_all_zeroes(lists ++ [diffList])
    end
  end

  def part2(filestream) do
    "todo"
  end
end
