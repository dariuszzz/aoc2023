defmodule Mix.Tasks.Aoc8 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input8.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&part1/1, [file])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
    {p2time, p2} = :timer.tc(&part2/1, [file])
    IO.puts "Part 2: #{p2} - took #{p2time/1000}ms"
  end

  def part1(filestream) do
    {moves, _, map} = parse_input(filestream)

    count_steps_while(moves, map, "AAA", fn curr_element -> curr_element == "ZZZ" end)
  end

  def part2(filestream) do
    {moves, elements, map} = parse_input(filestream)

    elements
      |> Enum.filter(fn elem -> String.ends_with?(elem, "A") end)
      |> Enum.map(fn starting_pos ->
        count_steps_while(moves, map, starting_pos, &String.ends_with?(&1, "Z"))
      end)
      |> Enum.reduce(fn steps, acc ->
        Integer.floor_div((steps * acc), Integer.gcd(steps, acc))
      end)
  end

  def count_steps_while(moves, map, starting_pos, pred) do
      moves
        |> Stream.cycle()
        |> Stream.transform({0, starting_pos}, fn move, {step, curr_element} ->
          case pred.(curr_element) do
            true -> {:halt, step}
            false ->
              {path1, path2} = Map.get(map, curr_element)
              case move do
                "L" -> {[step + 1], {step + 1, path1}}
                "R" -> {[step + 1], {step + 1, path2}}
              end
          end
        end)
        |> Enum.to_list()
        |> Enum.at(-1)
  end

  def parse_input(filestream) do
    moves = filestream
      |> Enum.take(1)
      |> Enum.at(0)
      |> String.trim()
      |> String.codepoints()

    { elements, map } = filestream
      |> Enum.drop(2)
      |> Enum.map(fn line ->
        line = String.trim(line)
        [element, paths] = String.split(line, " = ")
        [path1, path2] = String.split(paths, ", ")
        path1 = String.trim_leading(path1, "(")
        path2 = String.trim_trailing(path2, ")")

        {element, {path1, path2}}
      end)
      |> Enum.reduce({[], %{}}, fn {element, {path1, path2}}, {list, map} ->
        map = Map.put(map, element, {path1, path2})
        list = [ element | list ]

        { list, map }
      end)

    {moves, elements, map}
  end
end
