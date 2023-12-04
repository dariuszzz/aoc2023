defmodule Mix.Tasks.Aoc1 do
  use Mix.Task

  @type digit() :: String.t()

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input1.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&solution/2, [file, &get_numbers/1])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
    {p2time, p2} = :timer.tc(&solution/2, [file, &into_numbers/1])
    IO.puts "Part 2: #{p2} - took #{p2time/1000}ms"
  end

  @spec digit?(Integer.t()) :: boolean()
  def digit?(x) do
    case Integer.parse(x) do
      {_, ""} -> true
      _ -> false
    end
  end

  @spec get_numbers(String.t()) :: [digit()]
  def get_numbers(line) do
    numbers = String.codepoints(line)
      |> Enum.filter(&digit?/1)

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

  @spec find_digit_starting_at(integer(), String.t()) :: nil | digit()
  def find_digit_starting_at(x, str) do
    key = Map.keys(@digits)
      |> Enum.find(&check_if_word_at_x(x, &1, str))

    case key do
      nil -> nil
      _ -> @digits[key]
    end
  end

  @spec check_if_word_at_x(integer(), String.t(), String.t()) :: boolean()
  def check_if_word_at_x(x, word, str) do
    slice = String.slice(str, x..x + String.length(word) - 1)
    String.equivalent?(slice, word)
  end

  @spec to_digit(integer(), String.t()) :: digit()
  def to_digit(x, line) do
    char = String.at(line, x)
    case digit?(char) do
      true -> char
      false -> find_digit_starting_at(x, line)
    end
  end

  @spec into_numbers(String.t()) :: [digit()]
  def into_numbers(line) do
    numbers = 0..String.length(line) - 1
      |> Enum.map(&to_digit(&1, line))
      |> Enum.filter(fn x -> !is_nil(x) and String.length(x) != 0 end)

    [List.first(numbers), List.last(numbers)]
  end

  @spec solution(File.Stream.t(), (String.t() -> String.t())) :: integer()
  def solution(filestream, func) do
    filestream
      |> Enum.map(&String.trim(&1))
      |> Enum.map(&func.(&1))
      |> Enum.map(&Enum.join(&1, ""))
      |> Enum.map(&String.to_integer(&1))
      |> Enum.sum()
  end
end
