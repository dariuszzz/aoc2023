defmodule Mix.Tasks.Aoc2 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input2.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&part1/1, [file])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
    {p2time, p2} = :timer.tc(&part2/1, [file])
    IO.puts "Part 2: #{p2} - took #{p2time/1000}ms"
  end

  @spec minimum_cubes([[{integer(), String.t()}]]) :: {integer(), integer(), integer()}
  def minimum_cubes(sets) do
    List.flatten(sets)
      |> Enum.reduce({0, 0, 0}, fn {amount, color}, {r, g, b} ->
        case color do
          " red" when amount > r -> {amount, g, b}
          " green" when amount > g -> {r, amount, b}
          " blue" when amount > b -> {r, g, amount}
          _ -> {r, g, b}
        end
      end)
  end

  @spec part2(File.Stream.t()) :: integer()
  def part2(filestream) do
    filestream
      |> Enum.map(&parse/1)
      |> Enum.map(fn [ _ | sets ] -> sets end)
      |> Enum.map(&minimum_cubes/1)
      |> Enum.map(fn {r, g, b} -> r * g * b end)
      |> Enum.sum()
  end

  @spec part1_filter(list()) :: boolean()
  def part1_filter([ _ | sets ]) do
    List.flatten(sets)
      |> Enum.all?(fn set ->
        case set do
          {x, " red"} when x > 12 -> false
          {x, " green"} when x > 13 -> false
          {x, " blue"} when x > 14 -> false
          _ -> true
        end
      end)
  end

  @spec part1(File.Stream.t()) :: integer()
  def part1(filestream) do
    filestream
      |> Enum.map(&parse/1)
      |> Enum.filter(&part1_filter/1)
      |> Enum.map(fn [ game_id | _ ] -> game_id end)
      |> Enum.sum()
  end

  @spec parse(String.t()) :: [integer() | [{integer(), String.t()}]]
  def parse(line) do
      [ game | sets ] = String.split(line, ":")
      game_id = Enum.at(String.split(game, " "), 1)
      game_id = elem(Integer.parse(game_id), 0)

      sets = Enum.at(sets, 0)
      sets = String.split(sets, ";")
        |> Enum.map(&String.split(&1, ","))
        |> Enum.map(&Enum.map(&1, fn x ->
          trimmed = String.trim(x)
          Integer.parse(trimmed)
        end))

      [ game_id | sets ]
  end
end
