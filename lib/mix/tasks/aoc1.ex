defmodule Mix.Tasks.Aoc1 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/input.txt"
    file = File.stream!(path)

    IO.puts "Part 1: #{solution(file, &get_numbers/1)}"
    IO.puts "Part 2: #{solution(file, &into_numbers/1)}"
  end

  defguard is_digit(term) when
    term == "0"
    or term == "1"
    or term == "2"
    or term == "3"
    or term == "4"
    or term == "5"
    or term == "6"
    or term == "7"
    or term == "8"
    or term == "9"

  def get_numbers(line) do
    numbers = String.codepoints(line)
      |> Enum.filter(&(is_digit(&1)))

    [List.first(numbers), List.last(numbers)]
  end

  @digits %{
    "zero" => "0",
    "one" => "1",
    "two" => "2",
    "three" => "3",
    "four" => "4",
    "five" => "5",
    "six" => "6",
    "seven" => "7",
    "eight" => "8",
    "nine" => "9",
  }

  def into_numbers(line) do
    check_if_word_at_x = fn x, word, str ->
      slice = String.slice(str, x..x + String.length(word) - 1)
      String.equivalent?(slice, word)
    end

    find_digit_starting_at = fn x ->
      key = Map.keys(@digits)
        |> Enum.find(&check_if_word_at_x.(x, &1, line))

      case key do
        nil -> nil
        _ -> @digits[key]
      end
    end

    to_digit = fn
      x when is_digit(x) -> String.at(line, x)
      x -> find_digit_starting_at.(x)
    end

    numbers = 0..String.length(line) - 1
      |> Enum.map(to_digit)
      |> Enum.filter(fn x -> !is_nil(x) and String.length(x) != 0 end)

    [List.first(numbers), List.last(numbers)]
  end

  def solution(filestream, func) do
    filestream
      |> Enum.map(&String.trim(&1))
      |> Enum.map(&func.(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.map(&String.to_integer(&1))
      |> Enum.sum()
  end
end
