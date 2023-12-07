defmodule Mix.Tasks.Aoc6 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input6.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&part1/1, [file])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
    {p2time, p2} = :timer.tc(&part2/1, [file])
    IO.puts "Part 2: #{p2} - took #{p2time/1000}ms"
  end

  def part1(filestream) do
    [times, distances] = filestream
      |> Enum.take(2)

    <<"Time:", rest::binary>> = times
    times = String.split(rest, " ", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    <<"Distance:", rest::binary>> = distances
    distances = String.split(rest, " ", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    winning_strategies = times
      |> Enum.zip(distances)
      |> Enum.map(fn {time, distance_to_beat} ->
        0..time
          |> Enum.map(fn held -> (time - held) * held end)
          |> Enum.filter(fn distance -> distance > distance_to_beat end)
      end)
      |> Enum.map(&length/1)

    winning_strategies
      |> Enum.reduce(fn x, acc -> acc * x end)
  end

  def part2(filestream) do
    [times, distances] = filestream
      |> Enum.take(2)

    <<"Time:", rest::binary>> = times
    time = String.split(rest, " ", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.join("")
      |> String.to_integer()

    <<"Distance:", rest::binary>> = distances
    distance_to_beat = String.split(rest, " ", trim: true)
      |> Enum.map(&String.trim/1)
      |> Enum.join("")
      |> String.to_integer()

    0..time
      |> Enum.map(fn held -> (time - held) * held end)
      |> Enum.filter(fn distance -> distance > distance_to_beat end)
      |> length
  end
end
