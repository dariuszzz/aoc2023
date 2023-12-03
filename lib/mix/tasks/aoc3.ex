defmodule Mix.Tasks.Aoc3 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input3.txt"
    file = File.stream!(path)

    IO.puts "Part 1: #{part1(file)}"
    IO.puts "Part 2: #{part2(file)}"
  end

  def adjacent({char_x, char_y}, {start_x, y, end_x}) do
    abs(y - char_y) <= 1
    && char_x >= start_x - 1
    && char_x <= end_x + 1
  end

  def part1(filestream) do
      {numbers, special_chars} = parse(filestream)

      sum = numbers
        |> Enum.filter(fn {num_key, num_val} ->
          {start_x, y} = num_key
          end_x = start_x + String.length(num_val) - 1

          special_chars
            |> Enum.any?(fn {char_key, _} ->
              {char_x, char_y} = char_key

              adjacent({char_x, char_y}, {start_x, y, end_x})
            end)
        end)
        |> Enum.map(fn {_, num_val} ->
          String.to_integer(num_val)
        end)
        |> Enum.sum()

      sum
  end

  def part2(filestream) do
    {numbers, special_chars} = parse(filestream)

    special_chars
      |> Enum.filter(fn {_, char} -> char == "*" end)
      |> Enum.map(fn {char_key, _} ->
        adjacent_nums = numbers
          |> Enum.filter(fn {num_key, num_val} ->
            {start_x, y} = num_key
            end_x = start_x + String.length(num_val) - 1
            adjacent(char_key, {start_x, y, end_x})
          end)
          |> Enum.map(fn {_, num_val} -> String.to_integer(num_val) end)

        case adjacent_nums do
          [a, b] -> a * b
          _ -> 0
        end
      end)
      |> Enum.sum()
  end

  def parse(filestream) do
    roughly_parsed = filestream
      |> Enum.map(&String.trim/1)
      |> Enum.with_index()

    special_chars = roughly_parsed
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        String.codepoints(line)
          |> Enum.with_index()
          |> Enum.reject(fn {char, _} -> char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "."] end)
          |> Enum.reduce(acc, fn {char, x}, line_acc ->
            Map.put(line_acc, {x, y}, char)
          end)
      end)

    numbers = roughly_parsed
      |> Enum.reduce(%{}, fn {line, y}, acc ->
        res = String.codepoints(line <> ".")
          |> Enum.with_index()
          |> Enum.reduce({acc, {nil, ""}}, fn {char, x}, {line_acc, {initial_x, num}} ->
            case char in ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9"] do
              true when initial_x == nil -> {line_acc, {x, num <> char}}
              true -> {line_acc, {initial_x, num <> char}}
              false when num != "" -> {Map.put(line_acc, {initial_x, y}, num), {nil, ""}}
              false -> {line_acc, {initial_x, num}}
            end
          end)

        elem(res, 0)
      end)

    {numbers, special_chars}
  end
end
