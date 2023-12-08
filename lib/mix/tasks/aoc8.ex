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
    {moves, elements, map} = parse_input(filestream)

    stepsTaken = findZZZ(moves, 0, map, 0, ["AAA"])

    stepsTaken
  end

  def findZZZ(_, _, _, step, [ currElement | _ ] = elementsTraversed) when currElement == "ZZZ", do: step
  def findZZZ(moves, moveIndex, map, step, [ currElement | _ ] = elementsTraversed) when currElement != "ZZZ" do
    move = Enum.at(moves, moveIndex)
    {path1, path2} = Map.get(map, currElement)
    moveIndex = case moveIndex + 1 do
      x when x >= length(moves) -> 0
      x -> x
    end
    case move do
      _ when currElement == path1 and path1 == path2 -> step
      "L" -> findZZZ(moves, moveIndex, map, step + 1, [ path1 | elementsTraversed ])
      "R" -> findZZZ(moves, moveIndex, map, step + 1, [ path2 | elementsTraversed ])
    end
  end

  def findEndingInZ(_, _, _, step, [ currElement | _ ]) when binary_part(currElement, 2, 1) == "Z", do: step
  def findEndingInZ(moves, moveIndex, map, step, [ currElement | _ ] = elementsTraversed) when binary_part(currElement, 2, 1) != "Z" do
    move = Enum.at(moves, moveIndex)
    {path1, path2} = Map.get(map, currElement)
    moveIndex = case moveIndex + 1 do
      x when x >= length(moves) -> 0
      x -> x
    end
    case move do
      _ when currElement == path1 and path1 == path2 -> step
      "L" -> findEndingInZ(moves, moveIndex, map, step + 1, [ path1 | elementsTraversed ])
      "R" -> findEndingInZ(moves, moveIndex, map, step + 1, [ path2 | elementsTraversed ])
    end
  end

  def part2(filestream) do
    {moves, elements, map} = parse_input(filestream)

    elements
      |> Enum.filter(fn elem -> String.ends_with?(elem, "A") end)
      |> Enum.map(fn starting_pos ->
        findEndingInZ(moves, 0, map, 0, [starting_pos])
      end)
      |> Enum.reduce(fn steps, acc ->
        Integer.floor_div((steps * acc), Integer.gcd(steps, acc))
      end)
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
