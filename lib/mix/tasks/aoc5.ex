defmodule Mix.Tasks.Aoc5 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input5.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&part1/1, [file])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
  end

  def part1(filestream) do
    seeds = filestream
      |> Enum.take(1)
      |> Enum.reduce([], fn <<"seeds: ", rest::binary>>, acc ->
        rest
          |> String.trim
          |> String.split(" ")
          |> Enum.map(&String.to_integer/1)
      end)

    {maps, last_map} = filestream
      |> Enum.drop_while(fn line -> String.trim(line) != "" end)
      |> Enum.reject(fn line -> String.trim(line) == "" end)
      |> Enum.reduce({ [], [] }, fn line, { transforms, curr_transforms }  ->
        case String.split(line, ":") do
          [_, _] when length(curr_transforms) != 0 -> {[ Enum.reverse(curr_transforms) | transforms ], [] }
          [_, _] -> { transforms, curr_transforms }
          _ ->
            [destination_start, source_start, range] = line
              |> String.trim
              |> String.split(" ")
              |> Enum.map(&String.to_integer/1)

            { transforms, [ { destination_start, source_start, range } | curr_transforms ] }
        end
      end)

    maps = Enum.reverse([ Enum.reverse(last_map) | maps ])

    seeds
      |> Enum.map(fn seed ->
        maps
          |> Enum.reduce(seed, fn transforms, seed ->
            transforms
              |> Enum.reduce_while(seed, fn {destination_start, source_start, range}, seed ->
                source_range = source_start..(source_start + range - 1)
                # destination_range = destination_start..(destination_start + range - 1)
                case seed in source_range do
                  true ->
                    diff = seed - source_start
                    {:halt, destination_start + diff}
                  false -> {:cont, seed}
                end
              end)
          end)
      end)
      |> Enum.reduce(fn val, min -> min(val, min) end)
  end
end
