defmodule Mix.Tasks.Aoc3 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input3.txt"
    file = File.stream!(path)

    IO.puts "Part 1: #{part1(file)}"
    IO.puts "Part 2: #{part2(file)}"
  end

  def adjacent?({char_x, char_y}, {{num_x, num_y}, num_val}) do
    {start_x, y} = {num_x, num_y}
    end_x = start_x + String.length(num_val) - 1

    abs(y - char_y) <= 1
    && char_x >= start_x - 1
    && char_x <= end_x + 1
  end

  def part1(filestream) do
      {numbers, special_chars} = parse(filestream)

      sum = numbers
        |> Enum.filter(fn number_kv ->
          special_chars
            |> Enum.any?(fn {char_key, _} ->
              adjacent?(char_key, number_kv)
            end)
        end)
        |> Enum.map(fn {_, num_val} -> String.to_integer(num_val) end)
        |> Enum.sum()

      sum
  end

  def part2(filestream) do
    {numbers, special_chars} = parse(filestream)

    special_chars
      |> Enum.filter(fn {_, char} -> char == "*" end)
      |> Enum.map(fn {char_key, _} ->
        adjacent_nums = numbers
          |> Enum.filter(fn number_kv ->
            adjacent?(char_key, number_kv)
          end)
          |> Enum.map(fn {_, num_val} -> String.to_integer(num_val) end)

        case adjacent_nums do
          [a, b] -> a * b
          _ -> 0
        end
      end)
      |> Enum.sum()
  end

  @digits ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"]

  def parse(filestream) do
    trimmed_with_index = filestream
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()

    special_chars = trimmed_with_index
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        line
          |> String.codepoints()
          |> Enum.with_index()
          |> Enum.reject(fn {char, _} -> char in @digits or char == "." end)
          |> Enum.reduce(acc, fn {char, x}, line_acc ->
            Map.put(line_acc, {x, y}, char)
          end)
      end)

    numbers = trimmed_with_index
      |> Enum.reduce(%{}, fn {line, y}, map ->
        res = line <> "."
          |> String.codepoints()
          |> Enum.with_index()
          |> Enum.reduce({map, {0, ""}}, fn {char, x}, {line_map, {initial_x, num}} ->
            case char in @digits do
              true when initial_x == 0 -> {line_map, {x, num <> char}}
              true -> {line_map, {initial_x, num <> char}}
              false when num != "" ->
                line_map = Map.put(line_map, {initial_x, y}, num)
                {line_map, {0, ""}}
              false -> {line_map, {initial_x, num}}
            end
          end)

        elem(res, 0)
      end)

    {numbers, special_chars}
  end
end
